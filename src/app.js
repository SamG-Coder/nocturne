import {Engine} from './engine.js';
import {AudioBank} from './audio.js';
import {loadMemory,saveMemory} from './storage.js';

const canvas=document.querySelector('canvas'),boot=document.querySelector('#boot');
const status=document.querySelector('#status'),detail=document.querySelector('#detail');
const audio=new AudioBank();const engine=new Engine(canvas);
const params=new URLSearchParams(location.search),manual=params.has('test');
let ready=false,busy=false,polling=false,saving=false,faulted=false,last=0,accum=0,pollTime=0,saveTime=0;
let lastState=null,quality=3,resizeTimer,noticeTimer;
const widths=[640,960,1280,1600];
const requested=Number(params.get('width'));if(widths.includes(requested))quality=widths.indexOf(requested);
const keys=new Set(),pressed=new Set();const mouseHeld=[0,0],mousePressed=[0,0];
function notice(text){const e=document.querySelector('#notice');e.textContent=text;e.classList.add('show');clearTimeout(noticeTimer);noticeTimer=setTimeout(()=>e.classList.remove('show'),3800);}
function fatal(error){if(faulted)return;faulted=true;console.error(error);boot.hidden=false;document.body.classList.remove('ready');status.textContent='The hollow could not open.';detail.textContent=String(error?.message||error);document.querySelector('#retry').hidden=false;}
document.querySelector('#retry').onclick=()=>location.reload();
function dimensions(){const w=widths[quality];return [w,Math.round(w*innerHeight/innerWidth)];}
function fillInput(){
 const input=engine.input;const down=k=>keys.has(k)||pressed.has(k);
 input[0]=Number(down('KeyD')||down('ArrowRight'))-Number(down('KeyA')||down('ArrowLeft'));
 input[1]=Number(down('KeyS')||down('ArrowDown'))-Number(down('KeyW')||down('ArrowUp'));
 for(const [i,k]of [[6,'Space'],[7,'KeyE'],[8,'Enter'],[9,'Escape'],[11,'KeyT'],[12,'KeyR'],[13,'KeyL'],[14,'KeyH']])input[i]=Number(down(k));
 input[10]=down('Digit1')?1:down('Digit2')?2:down('Digit3')?3:0;
 input[4]=mouseHeld[0]||mousePressed[0];input[5]=mouseHeld[1]||mousePressed[1];
 engine.writeInput();pressed.clear();mousePressed.fill(0);
}
addEventListener('keydown',e=>{
 if(['Space','ArrowUp','ArrowDown','ArrowLeft','ArrowRight','Tab','F6','F7'].includes(e.code))e.preventDefault();
 if(!ready||faulted)return;
 audio.unlock().catch(()=>{});
 if(!e.repeat){
  if(e.code==='KeyF'){document.fullscreenElement?document.exitFullscreen().catch(()=>{}):canvas.requestFullscreen().catch(()=>notice('Fullscreen is unavailable.'));return;}
  if(e.code==='KeyM'){audio.toggle();notice(audio.enabled?'Sound on':'Sound off');return;}
  if(e.code==='KeyQ'){quality=(quality+1)%widths.length;resize();notice(`Render width: ${widths[quality]} pixels`);return;}
  if(e.code==='F6'){exportMemory();return;}
  if(e.code==='F7'){pauseForFile().then(()=>document.querySelector('#memory-file').click());return;}
 }
 const code=e.code==='Tab'?'KeyH':e.code;keys.add(code);if(!e.repeat)pressed.add(code);
});
addEventListener('keyup',e=>keys.delete(e.code==='Tab'?'KeyH':e.code));
function clearControls(){keys.clear();pressed.clear();mouseHeld.fill(0);mousePressed.fill(0);if(engine.input){engine.input.fill(0);engine.input[2]=.15;}}
addEventListener('blur',clearControls);
addEventListener('visibilitychange',()=>{clearControls();last=0;accum=0;if(document.hidden&&ready)persist();});
canvas.addEventListener('pointermove',e=>{if(!engine.input)return;const r=canvas.getBoundingClientRect();engine.input[2]=(e.clientX-r.left)/r.width*2-1;engine.input[3]=(e.clientY-r.top)/r.height*2-1;});
canvas.addEventListener('pointerdown',e=>{e.preventDefault();canvas.focus();audio.unlock().catch(()=>{});if(!ready)return;mouseHeld[e.button===2?1:0]=1;mousePressed[e.button===2?1:0]=1;canvas.setPointerCapture(e.pointerId);});
canvas.addEventListener('pointerup',e=>{mouseHeld[e.button===2?1:0]=0;});
canvas.addEventListener('pointercancel',()=>{mouseHeld.fill(0);mousePressed.fill(0);});
canvas.addEventListener('contextmenu',e=>e.preventDefault());
async function resize(){clearTimeout(resizeTimer);resizeTimer=setTimeout(async()=>{
 if(!ready||busy||faulted){if(ready&&!faulted)resize();return;}busy=true;
 try{await engine.resize(...dimensions());}catch(e){fatal(e);}finally{busy=false;last=0;accum=0;}
},160);}
addEventListener('resize',resize);
async function persist(){if(saving||!ready||faulted)return;saving=true;try{await saveMemory(await engine.snapshot());}catch(e){console.warn('Local memory was not saved:',e);}finally{saving=false;}}
async function exportMemory(){try{const snapshot=await engine.snapshot();const url=URL.createObjectURL(new Blob([JSON.stringify(snapshot)],{type:'application/json'}));const a=document.createElement('a');a.href=url;a.download='nocturne-memory.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);notice('Weights, optimizer and enemy lineages exported.');}catch(e){notice(e.message);}}
async function pauseForFile(){if(lastState?.[8]===1){while(busy)await new Promise(r=>setTimeout(r,20));busy=true;engine.input[9]=1;engine.writeInput();engine.frame(1);engine.input[9]=0;engine.writeInput();await engine.runtime.idle();busy=false;}}
document.querySelector('#memory-file').addEventListener('change',async e=>{const f=e.target.files[0];e.target.value='';if(!f)return;try{if(f.size>256000)throw Error('Memory files must be under 256 KB.');const s=JSON.parse(await f.text());await engine.restore(s);await saveMemory(s);notice('Memory imported. New enemies inherit the restored lineages.');}catch(error){notice(error.message);}});
async function poll(){if(polling)return;polling=true;try{const s=await engine.state();audio.observe(s);if(lastState&&s[8]!==lastState[8]&&(s[8]===4||s[8]===5))persist();lastState=s;}catch(e){fatal(e);}finally{polling=false;}}
function frame(now){
 requestAnimationFrame(frame);if(!ready||manual||faulted||document.hidden)return;
 if(!last)last=now;const elapsed=Math.min(.1,(now-last)/1000);last=now;
 // Bounded queue; never build an unbounded backlog behind the renderer.
 accum=Math.min(accum+elapsed,4/60);if(busy)return;
 const steps=Math.min(4,Math.floor(accum*60));if(!steps)return;
 accum-=steps/60;fillInput();busy=true;
 try{engine.frame(steps);engine.device.queue.onSubmittedWorkDone().then(()=>busy=false).catch(fatal);}catch(e){fatal(e);busy=false;}
 if(now-pollTime>80){pollTime=now;poll();}if(now-saveTime>30000){saveTime=now;persist();}
}
async function start(){try{
 const [width,height]=dimensions();
 await engine.init((text,f)=>{status.textContent=text;document.querySelector('#progress').style.width=`${Math.round(f*100)}%`;},{width,height,recompile:params.has('compile'),onError:fatal});
 if(!manual){try{const stored=await loadMemory();if(stored){await engine.restore(stored);detail.textContent='The hollow remembers you.';}}catch(e){notice('Local memory unavailable; this run can still be exported with F6.');}}
 audio.install(await engine.soundTable());
 ready=true;document.body.classList.add('ready');boot.hidden=true;canvas.focus();engine.writeInput();engine.frame(1,true);await engine.runtime.idle();
 // Intentional testing/debugging surface. No JavaScript AI or physics lives here.
 window.nocturne={engine,audio,persist,exportMemory,ready:true};
 requestAnimationFrame(frame);
}catch(e){fatal(e);}}
start();
