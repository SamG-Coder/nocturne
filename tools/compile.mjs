import fs from 'node:fs/promises';
import {compile} from '../vendor/cuda-webshader/compiler/compiler.js';
const root=new URL('../',import.meta.url);
const groups={game:{initialise:64,newRun:1,stepWorld:1,stepProjectiles:64,stepEnemies:64,evolvePopulation:1},learning:{recordExperience:1,prepareBatch:32,forwardBatch:32,backwardBatch:32,computeGradient:64,updateWeights:64,inferPlayer:1},render:{buildTiles:64,renderGround:[8,8,1],renderWorld:[8,8,1]},ui:{renderUI:[8,8,1]},audio:{synthAudio:128}};
const common=await fs.readFile(new URL('kernels/common.cu',root),'utf8');
await fs.mkdir(new URL('generated/',root),{recursive:true});const manifest=[];
for(const [file,entries]of Object.entries(groups)){
 const text=await fs.readFile(new URL(`kernels/${file}.cu`,root),'utf8');
 for(const [entry,block]of Object.entries(entries)){
  const workgroupSize=Array.isArray(block)?block:[block,1,1];
  try{
   const source=common+'\n'+text;
   const artifact=compile(source,{entry,workgroupSize});
   const {ast,kernel,...portable}=artifact; // Compiler AST is not needed at runtime.
   await fs.writeFile(new URL(`generated/${entry}.json`,root),JSON.stringify(portable));
   await fs.writeFile(new URL(`generated/${entry}.wgsl`,root),artifact.wgsl);
   manifest.push({entry,file,workgroupSize,bindings:artifact.metadata.bindings.map(x=>x.name),uniformBytes:artifact.metadata.uniformSize});
   console.log(`OK ${entry}: ${artifact.wgsl.length} bytes; ${artifact.metadata.bindings.length} buffers`);
  }catch(e){console.error(`FAILED ${file}/${entry}:`,e.message);process.exitCode=1;}
 }
}
await fs.writeFile(new URL('generated/manifest.json',root),JSON.stringify(manifest,null,2));
// Convenient all-in-one source for inspection/integration; split files remain authoritative.
let combined='// NOCTURNE / generated single-file CUDA source.\n// Rebuild from kernels/*.cu with npm run build. See docs/ARCHITECTURE.md for dispatch order.\n';
for(const file of ['common',...Object.keys(groups)])combined+='\n// ===== '+file.toUpperCase()+' =====\n'+await fs.readFile(new URL(`kernels/${file}.cu`,root),'utf8');
await fs.writeFile(new URL('Nocturne.cu',root),combined);
