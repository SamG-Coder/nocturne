/** Playback only: samples originate in kernels/audio.cu. */
export class AudioBank {
 constructor(){this.ctx=null;this.enabled=true;this.table=null;this.last=new Float32Array(128);this.voices=0;}
 async unlock(){
  if(!this.ctx){this.ctx=new AudioContext();this.gain=this.ctx.createGain();this.gain.gain.value=0.65;this.gain.connect(this.ctx.destination);if(this.table)this.install(this.table);}
  await this.ctx.resume();
 }
 install(table){this.table=table;if(!this.ctx||this.sounds)return;this.sounds=[];
  for(let k=0;k<8;k++){const b=this.ctx.createBuffer(1,22050,22050);b.copyToChannel(table.subarray(k*22050,(k+1)*22050),0);this.sounds.push(b);}
  const ambient=this.ctx.createBuffer(1,8*22050,22050);ambient.copyToChannel(table.subarray(8*22050),0);
  this.ambient=this.ctx.createBufferSource();this.ambient.buffer=ambient;this.ambient.loop=true;const volume=this.ctx.createGain();volume.gain.value=0.36;this.ambient.connect(volume).connect(this.gain);this.ambient.start();
 }
 play(id){if(!this.enabled||!this.sounds||this.ctx.state!=='running'||this.voices>12)return;const source=this.ctx.createBufferSource();source.buffer=this.sounds[id];source.connect(this.gain);this.voices++;source.onended=()=>this.voices--;source.start();}
 observe(s){for(const [index,sound]of [[52,0],[53,1],[54,2],[55,3],[56,4],[57,5],[58,6],[22,7]])if(s[index]>this.last[index])this.play(sound);this.last.set(s);}
 toggle(){this.enabled=!this.enabled;if(this.gain)this.gain.gain.setTargetAtTime(this.enabled?0.65:0,this.ctx.currentTime,0.1);}
}
