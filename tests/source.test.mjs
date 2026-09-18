import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import {compile} from '../vendor/cuda-webshader/compiler/compiler.js';
import {packScalars,validateWorkgroup} from '../vendor/cuda-webshader/runtime/runtime.js';
import {installConstants,mockDevice,mockCanvas} from './mock-device.mjs';
import {Engine} from '../src/engine.js';
const root=new URL('../',import.meta.url);
const manifest=JSON.parse(await fs.readFile(new URL('generated/manifest.json',root),'utf8'));

test('all 17 CUDA entry points have matching generated artifacts and source',async()=>{
 assert.equal(manifest.length,17);const common=await fs.readFile(new URL('kernels/common.cu',root),'utf8');
 for(const m of manifest){const source=common+'\n'+await fs.readFile(new URL(`kernels/${m.file}.cu`,root),'utf8');const artifact=compile(source,{entry:m.entry,workgroupSize:m.workgroupSize});const saved=JSON.parse(await fs.readFile(new URL(`generated/${m.entry}.json`,root),'utf8'));assert.equal(artifact.wgsl,saved.wgsl,m.entry);assert.deepEqual(artifact.metadata,saved.metadata,m.entry);assert.ok(saved.metadata.bindings.length<=8);assert.ok(saved.metadata.uniformSize<=65536);}
});
test('actual host binds, records, resizes, saves and restores against the runtime API contract',async()=>{
 installConstants();const device=mockDevice();const adapter={info:{vendor:'mock; not a GPU test'},requestDevice:async()=>device};
 Object.defineProperty(globalThis,'navigator',{configurable:true,value:{gpu:{requestAdapter:async()=>adapter}}});
 const originalFetch=globalThis.fetch;
 globalThis.fetch=async url=>{const file=new URL(url);assert.ok(file.href.startsWith(root.href));return new Response(await fs.readFile(file));};
 try{
  const game=await new Engine(mockCanvas()).init(()=>{},{width:641,height:361});
  assert.equal(game.width,704);assert.equal(game.height,368);assert.equal(game.buffers.E0.byteLength,320*48*4);
  game.input[0]=1;game.writeInput();game.frame(4);await game.runtime.idle();assert.equal(game.frames,4);assert.equal(game.parity,0);
  assert.ok(device.calls.some(c=>c[0]==='present'&&c[1]===704));
  await game.resize(960,540);game.frame(1);assert.equal(game.parity,1);
  const weights=Float32Array.from({length:610},(_,i)=>Math.sin(i)*.2);game.runtime.write(game.buffers.W,weights);
  const snap=await game.snapshot();assert.deepEqual(snap.fields.W,Array.from(weights));
  snap.fields.W[0]=.34;await game.restore(snap);const restored=await game.runtime.read(game.buffers.W);assert.equal(restored[0],Math.fround(.34));
  const bad=structuredClone(snap);bad.fields.W[5]=Infinity;await assert.rejects(()=>game.restore(bad));
  const bad2=structuredClone(snap);bad2.fields.G[1]=1.5;await assert.rejects(()=>game.restore(bad2));
  const bad3=structuredClone(snap);bad3.fields.V[0]=-1;await assert.rejects(()=>game.restore(bad3));
  assert.equal((await game.runtime.read(game.buffers.W))[0],Math.fround(.34),'rejected import is transactional');
  for(const m of manifest){const a=game.kernels[m.entry].artifact;validateWorkgroup(a.metadata,device.limits);}
  game.runtime.dispose();
 }finally{globalThis.fetch=originalFetch;delete globalThis.navigator;}
});
test('all visible game pixels use CUDA compute output, not a JavaScript scene renderer',async()=>{
 const engine=await fs.readFile(new URL('src/engine.js',root),'utf8');const app=await fs.readFile(new URL('src/app.js',root),'utf8');
 assert.ok(engine.includes('copyBufferToTexture'));assert.ok(!engine.includes('createRenderPipeline'));assert.ok(!engine.includes('createShaderModule'));
 assert.ok(!/three|pixi|babylon|tensorflow|onnx/i.test(engine+app));
 for(const m of manifest)assert.ok(m.file&&m.entry);
});
