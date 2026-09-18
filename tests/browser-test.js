import {Engine} from '../src/engine.js';
const log=document.querySelector('#log');
const say=s=>{log.textContent+=s+'\n';};
const check=(ok,s)=>{if(!ok)throw Error(s);say('PASS '+s);};
document.querySelector('#go').onclick=async function(){this.disabled=true;let e;
 try{
  e=await new Engine(document.querySelector('canvas')).init((s)=>{document.title=s;},{width:640,height:360,onError:x=>say('GPU ERROR: '+x.message)});
  say(JSON.stringify(e.info,null,2));check(e.errors.length===0,'all 17 WGSL modules and pipelines validate on this GPU');
  const step=async(n=1)=>{e.writeInput();e.frame(n,false);await e.runtime.idle();};
  e.input[8]=1;await step();e.input[8]=0;await step();check((await e.state())[8]===1,'begin a run');
  const start=(await e.state())[0];e.input[0]=1;for(let k=0;k<8;k++)await step(4);check((await e.state())[0]>start+60,'CUDA movement');
  e.input[0]=0;e.input[9]=1;await step();e.input[9]=0;const pauseTime=(await e.state())[6];await step(4);check((await e.state())[6]===pauseTime,'pause holds game time');
  e.input[9]=1;await step();e.input[9]=0;await step();
  const s=await e.state();s[4]=100000;s[5]=100000;e.runtime.write(e.buffers.S,s);
  const old=await e.runtime.read(e.buffers.W);
  for(let k=0;k<180;k++){const a=k*.045;e.input[0]=Math.cos(a);e.input[1]=Math.sin(a);e.input[10]=1;await step(4);if(k%45===0)say('Training fixture: '+Math.round(k/180*100)+'%');}
  const trained=await e.runtime.read(e.buffers.W),brain=await e.brain();
  check(brain[0]>10,'online training dispatches execute');check(trained.some((v,i)=>v!==old[i]),'weights actually change');check([...trained,...brain].every(Number.isFinite),'finite neural weights and metrics');
  e.input[13]=1;await step();e.input[13]=0;const frozen=await e.runtime.read(e.buffers.W);const time=(await e.state())[6];for(let k=0;k<30;k++)await step(4);
  check((await e.runtime.read(e.buffers.W)).every((v,i)=>v===frozen[i]),'learning freeze holds weights exactly');check((await e.state())[6]>time+1.5,'gameplay continues with frozen weights');
  const snapshot=await e.snapshot();await e.restore(snapshot);check((await e.runtime.read(e.buffers.W)).every((v,i)=>v===snapshot.fields.W[i]),'memory round trip');
  const final=await e.state();final[4]=94;final[5]=125;e.runtime.write(e.buffers.S,final);e.frame(0,true);await e.runtime.idle();
  check(e.errors.length===0,'no uncaptured WebGPU errors');say('PASS. This run used the GPU, not the mock-device contract test.');document.title='Nocturne — GPU checks passed';
 }catch(error){say('FAIL '+(error.stack||error));document.title='Nocturne — GPU check failed';}finally{this.disabled=false;}
};
