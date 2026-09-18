import {cp,mkdir,rm,writeFile} from 'node:fs/promises';
const root=new URL('../',import.meta.url),dist=new URL('../dist/',import.meta.url);
await rm(dist,{recursive:true,force:true});
await mkdir(dist,{recursive:true});
for(const name of ['index.html','style.css','src','generated','kernels','vendor','LICENSE','README.md','docs','tests/browser.html','tests/browser-test.js'])
 await cp(new URL(name,root),new URL(name,dist),{recursive:true});
await writeFile(new URL('.nojekyll',dist),'');
console.log('Built dist/ — static HTTPS host. No runtime external downloads.');
