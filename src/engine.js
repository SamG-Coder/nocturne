import {GpuRuntime} from '../vendor/cuda-webshader/runtime/runtime.js';

/** WebGPU transport only. All simulation, rendering and training are CUDA kernels. */
export class Engine {
  constructor(canvas){this.canvas=canvas;this.width=0;this.height=0;this.parity=0;this.frames=0;this.errors=[];this.inFlight=0;}
  async init(progress=()=>{}, options={}){
    if(!navigator.gpu)throw Error('WebGPU is unavailable. Use Chrome or Edge with hardware acceleration, on localhost or HTTPS.');
    const adapter=await navigator.gpu.requestAdapter({powerPreference:'high-performance'});
    if(!adapter)throw Error('No WebGPU adapter. Check browser GPU settings and your graphics driver.');
    const device=await adapter.requestDevice();
    this.runtime=new GpuRuntime(device,{adapter,ownsDevice:true,uniformCapacity:262144,onError:e=>{this.errors.push(String(e.message||e));options.onError?.(e);}});
    this.device=device;this.context=this.canvas.getContext('webgpu');this.info=this.runtime.describe();
    this.kernels={};this.manifest=await (await fetch(new URL('../generated/manifest.json',import.meta.url))).json();
    let compile=null,common='';
    if(options.recompile){
      ({compile}=await import('../vendor/cuda-webshader/compiler/compiler.js'));
      common=await(await fetch(new URL('../kernels/common.cu',import.meta.url))).text();
    }
    const sources=new Map();
    for(let i=0;i<this.manifest.length;i++){
      const spec=this.manifest[i];progress(`Forging ${spec.entry}`,i/this.manifest.length);
      let artifact;
      if(compile){
        if(!sources.has(spec.file))sources.set(spec.file,await(await fetch(new URL(`../kernels/${spec.file}.cu`,import.meta.url))).text());
        artifact=compile(common+'\n'+sources.get(spec.file),{entry:spec.entry,workgroupSize:spec.workgroupSize});
      }else{
        const response=await fetch(new URL(`../generated/${spec.entry}.json`,import.meta.url));if(!response.ok)throw Error('Missing kernel: '+spec.entry);artifact=await response.json();
      }
      this.kernels[spec.entry]=await this.runtime.kernel(artifact);
    }
    const rt=this.runtime;
    const sizes={S:128,I:32,E0:320*48,E1:320*48,P:128*10,W:610,M:610,V:610,G:640,Brain:32,R:4096*28,Work:32*88,Grad:610};
    this.buffers=Object.fromEntries(Object.entries(sizes).map(([name,count])=>[name,rt.createBuffer(count*4,{label:name})]));
    this.input=new Float32Array(32);this.input[2]=0.15;
    const seed=options.seed??1788;
    rt.batch().dispatch(this.bind('initialise',{seed}),[10]).dispatch(this.bind('newRun',{seed}),[1]).submit();
    await rt.idle();
    await this.resize(options.width??1280,options.height??720);
    this.buildBindings();
    return this;
  }
  bind(entry,scalars={},replacements={}){
    const all={...this.buffers,...replacements};
    const kernel=this.kernels[entry];
    const buffers=Object.fromEntries(kernel.artifact.metadata.bindings.map(p=>{
      const resource=all[p.name];if(!resource)throw Error('Unbound resource '+entry+'.'+p.name);return[p.name,resource];
    }));
    return kernel.bind(buffers,scalars);
  }
  buildBindings(){
    const globals={aspect:this.width/this.height,dt:1/60};
    this.bindings=[0,1].map(p=>{
      const old=this.buffers['E'+p],next=this.buffers['E'+(1-p)];
      return {
        world:this.bind('stepWorld',globals,{E:old}),
        projectiles:this.bind('stepProjectiles',{dt:1/60}),
        enemies:this.bind('stepEnemies',globals,{Old:old,E:next}),
        evolve:this.bind('evolvePopulation'),
        record:this.bind('recordExperience',{}, {E:next}),
        prepare:this.bind('prepareBatch'),forward:this.bind('forwardBatch'),backward:this.bind('backwardBatch'),
        grad:this.bind('computeGradient'),update:this.bind('updateWeights'),infer:this.bind('inferPlayer'),
        tiles:this.bind('buildTiles',{width:this.width,height:this.height},{E:old}),
        render:this.bind('renderWorld',{width:this.width,height:this.height},{E:old}),
        ui:this.bind('renderUI',{width:this.width,height:this.height})
      };
    });
  }
  async resize(width,height){
    // Buffer-to-canvas texture copies use 256-byte-aligned rows (64 RGBA pixels).
    width=Math.max(384,Math.ceil(width/64)*64);height=Math.max(256,Math.ceil(height/8)*8);
    if(this.width===width&&this.height===height)return;
    await this.runtime.idle();
    for(const key of ['Pixels','Tiles'])if(this.buffers[key])this.runtime.destroyBuffer(this.buffers[key]);
    this.width=this.canvas.width=width;this.height=this.canvas.height=height;
    this.buffers.Pixels=this.runtime.createBuffer(width*height*4,{label:'CUDA final RGBA8 image'});
    this.buffers.Tiles=this.runtime.createBuffer(Math.ceil(width/32)*Math.ceil(height/32)*64*4,{label:'GPU screen tile list'});
    this.context.configure({device:this.device,format:'rgba8unorm',usage:GPUTextureUsage.COPY_DST|GPUTextureUsage.RENDER_ATTACHMENT,alphaMode:'opaque'});
    if(this.bindings)this.buildBindings();
  }
  writeInput(values=this.input){this.input.set(values);this.runtime.write(this.buffers.I,this.input);}
  tick(batch){
    const b=this.bindings[this.parity];
    batch.dispatch(b.world,[1]).dispatch(b.projectiles,[2]).dispatch(b.enemies,[5]).dispatch(b.evolve,[1])
      .dispatch(b.record,[1]).dispatch(b.prepare,[1]).dispatch(b.forward,[1]).dispatch(b.backward,[1])
      .dispatch(b.grad,[10]).dispatch(b.update,[10]).dispatch(b.infer,[1]);
    this.parity=1-this.parity;this.frames++;
  }
  render(batch){
    const b=this.bindings[this.parity];
    batch.dispatch(b.tiles,[Math.ceil(Math.ceil(this.width/32)*Math.ceil(this.height/32)/64)])
      .dispatch(b.render,[Math.ceil(this.width/8),Math.ceil(this.height/8)])
      .dispatch(b.ui,[Math.ceil(this.width/8),Math.ceil(this.height/8)]);
    batch.endPass();
    batch.encoder.copyBufferToTexture({buffer:this.buffers.Pixels.gpuBuffer,bytesPerRow:this.width*4,rowsPerImage:this.height},{texture:this.context.getCurrentTexture()},[this.width,this.height]);
  }
  frame(ticks=1,draw=true){
    const batch=this.runtime.batch({label:'Nocturne / CUDA frame'});
    for(let i=0;i<ticks;i++)this.tick(batch);
    if(draw)this.render(batch);batch.submit();
  }
  async state(){return this.runtime.read(this.buffers.S);}
  async brain(){return this.runtime.read(this.buffers.Brain);}
  async snapshot(){
    await this.runtime.idle();
    const fields=['W','M','V','G','Brain'];const result={schema:'nocturne-memory',version:1,savedAt:new Date().toISOString(),fields:{}};
    // One queue-ordered snapshot batch: never mix weights from different training steps.
    const total=fields.reduce((n,k)=>n+this.buffers[k].byteLength,0);
    const stage=this.device.createBuffer({size:total,usage:GPUBufferUsage.COPY_DST|GPUBufferUsage.MAP_READ});
    const encoder=this.device.createCommandEncoder();let offset=0;
    for(const key of fields){encoder.copyBufferToBuffer(this.buffers[key].gpuBuffer,0,stage,offset,this.buffers[key].byteLength);offset+=this.buffers[key].byteLength;}
    this.device.queue.submit([encoder.finish()]);await stage.mapAsync(GPUMapMode.READ);
    const values=new Float32Array(stage.getMappedRange());let at=0;
    for(const key of fields){const length=this.buffers[key].byteLength/4;result.fields[key]=Array.from(values.subarray(at,at+length));at+=length;}
    stage.unmap();stage.destroy();return result;
  }
  async restore(snapshot){
    if(snapshot?.schema!=='nocturne-memory'||snapshot?.version!==1)throw Error('Not a compatible Nocturne memory file.');
    const keys=['W','M','V','G','Brain'];const data={};
    // Validate the ENTIRE file before touching any GPU buffer.
    for(const key of keys){const a=snapshot.fields?.[key];if(!Array.isArray(a)||a.length!==this.buffers[key].byteLength/4||a.some(v=>typeof v!=='number'||!Number.isFinite(v)||!Number.isFinite(Math.fround(v))))throw Error('Invalid memory buffer '+key);data[key]=new Float32Array(a);}
    if(data.V.some(v=>v<0||v>10000)||data.W.some(v=>Math.abs(v)>100)||data.M.some(v=>Math.abs(v)>100)||data.Brain.some(v=>Math.abs(v)>10000000)||data.Brain[0]<0)throw Error('Memory values exceed safe optimizer bounds.');
    for(let i=0;i<40;i++){for(let j=0;j<6;j++)if(data.G[i*16+j]<0||data.G[i*16+j]>1)throw Error('Invalid enemy traits.');for(let j=6;j<16;j++)if(data.G[i*16+j]<0||data.G[i*16+j]>10000000)throw Error('Invalid lineage history.');}
    // Replay belongs to a run and is never restored from a previous world's positions.
    data.Brain[7]=0;data.Brain[10]=0;data.Brain[4]=0;
    await this.runtime.idle();for(const key of keys)this.runtime.write(this.buffers[key],data[key]);
  }
  async soundTable(){
    const count=22050*16;const audio=this.runtime.createBuffer(count*4,{label:'CUDA synthesised sound bank'});
    this.runtime.batch().dispatch(this.bind('synthAudio',{count,sampleRate:22050},{Audio:audio}),[Math.ceil(count/128)]).submit();
    const values=await this.runtime.read(audio);this.runtime.destroyBuffer(audio);return values;
  }
}
