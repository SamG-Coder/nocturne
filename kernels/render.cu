// Every visible world pixel is computed here. No raster scene, imported sprites or Three.js.
__device__ float4 paint(float4 base,float4 pigment,float mask) {
 // Straight-alpha source-over. Sprite buffers start transparent, so RGB must
 // not be attenuated twice before the sprite is composited onto the world.
 float a=sat(mask)*sat(pigment.w);
 float outA=a+base.w*(1.0f-a);
 if(outA<0.00001f)return make_float4(0.0f,0.0f,0.0f,0.0f);
 float keep=base.w*(1.0f-a);
 return make_float4((pigment.x*a+base.x*keep)/outA,(pigment.y*a+base.y*keep)/outA,(pigment.z*a+base.z*keep)/outA,outA);
}
__device__ float4 enemyArt(float x,float y,const float* E,int b,float time,float aa) {
 int type=(int)E[b+6];float age=E[b+7];float elite=E[b+35];float scale=elite>0.5f?1.48f:1.0f;
 x/=scale;y/=scale;aa/=scale;float walk=sinf(age*(type==1?15.0f:10.0f)+E[b+12]);
 float moving=sat(len2(E[b+2],E[b+3])/60.0f);float bob=fabsf(walk)*moving*1.6f;
 float4 c=make_float4(0.0f,0.0f,0.0f,0.0f);
 if(E[b+4]<0.0f) {
  float stain=ink(len2(x/1.7f,y/0.8f)-15.0f,aa*2.0f)*(0.50f+0.2f*noise2(x*0.3f,y*0.3f));
  c=make_float4(0.13f,0.034f,0.029f,stain*sat(1.0f-E[b+18]/16.0f));
  float bones=ink(segment(x,y,-9.0f,-3.0f,10.0f,2.0f)-1.3f,aa)*0.3f;
  c=paint(c,color(0.35f,0.32f,0.25f),bones);
  if(E[b+38]>0.0f) {
   float yy=y+6.0f+sinf(time*3.0f+E[b+12])*2.0f;float gem=fabsf(x)*0.85f+fabsf(yy)*0.65f-4.0f;
   float glow=0.3f*expf(-len2(x,yy)/10.0f);c=paint(c,color(0.40f,0.33f,0.16f),glow);
   c=paint(c,color(0.87f,0.74f,0.42f),ink(gem,aa));c=paint(c,color(1.0f,0.95f,0.74f),ink(gem+2.0f,aa));
  }
  return c;
 }
 float yy=y+bob;float shade=0.75f+0.16f*noise2(x*0.48f,yy*0.48f)+0.12f*sat(-x/15.0f);
 if(type==1) {
  // Lean, low, four-legged carrion hound.
  float fx=E[b+2];float fy=E[b+3];float fl=fmaxf(1.0f,len2(fx,fy));fx/=fl;fy/=fl;
  float rx=x*fx+yy*fy;float ry=-x*fy+yy*fx;
  float body=len2(rx/1.8f,ry)-8.0f;
  c=paint(c,color(0.24f*shade,0.23f*shade,0.21f*shade),ink(body,aa));
  c=paint(c,color(0.36f,0.34f,0.29f),ink(len2((rx-12.0f)/1.2f,ry)-6.0f,aa));
  for(int k=0;k<4;k++) {float side=k%2==0?-1.0f:1.0f;float leg=k<2?-9.0f:7.0f;float step=walk*(k%2==0?1.0f:-1.0f)*3.0f;
   c=paint(c,color(0.22f,0.21f,0.18f),ink(segment(rx,ry,leg,side*5.0f,leg+step,side*12.0f)-1.5f,aa));}
  c=paint(c,color(0.12f,0.12f,0.11f),ink(segment(rx,ry,-11.0f,0.0f,-23.0f,sinf(age*9.0f)*5.0f)-2.0f,aa));
  c=paint(c,color(0.67f,0.16f,0.08f),ink(len2(rx-15.0f,fabsf(ry)-3.5f)-1.1f,aa));
  c=paint(c,color(0.59f,0.54f,0.43f),ink(boxd(rx-19.0f,ry,3.0f,2.0f),aa));
 } else {
  float width=type==3?17.0f:(type==4?9.0f:11.0f);float top=type==3?-34.0f:-29.0f;
  float step=walk*moving*3.5f;
  c=paint(c,color(0.13f,0.13f,0.12f),ink(segment(x,yy,-5.0f,-4.0f,-7.0f,3.0f+step)-3.0f,aa));
  c=paint(c,color(0.16f,0.16f,0.14f),ink(segment(x,yy,5.0f,-4.0f,7.0f,3.0f-step)-3.0f,aa));
  float body=fmaxf(fabsf(x)-(width+(yy+18.0f)*0.16f),fmaxf(top+8.0f-yy,yy+3.0f));
  float4 cloth=color(0.27f*shade,0.28f*shade,0.23f*shade);
  if(type==2)cloth=color(0.33f*shade,0.17f*shade,0.16f*shade);
  if(type==3)cloth=color(0.32f*shade,0.28f*shade,0.24f*shade);
  if(type==4)cloth=color(0.20f*shade,0.29f*shade,0.30f*shade);
  c=paint(c,cloth,ink(body,aa));
  float seam=ink(fabsf(x-sinf(yy*0.19f)*2.0f)-0.6f,aa)*ink(body+1.0f,aa);
  c=paint(c,color(0.095f,0.10f,0.087f),seam);
  float swing=E[b+8]==4.0f?8.0f:0.0f;
  c=paint(c,cloth*0.85f,ink(segment(x,yy,-width+2.0f,-22.0f,-width-5.0f-swing,-5.0f+step)-3.0f,aa));
  c=paint(c,cloth*1.2f,ink(segment(x,yy,width-2.0f,-22.0f,width+4.0f+swing,-7.0f-step)-3.0f,aa));
  float head=len2(x*0.92f,yy-(top+2.0f))-7.6f;
  c=paint(c,color(0.47f*shade,0.45f*shade,0.36f*shade),ink(head,aa));
  if(type==2||type==4) {
   c=paint(c,cloth*0.75f,ink(head-2.5f,aa));
   c=paint(c,color(0.042f,0.049f,0.047f),ink(len2(x,yy-(top+3.0f))-5.6f,aa));
  }
  c=paint(c,color(0.09f,0.079f,0.062f),ink(boxd(x,yy-(top+5.0f),4.8f,2.2f),aa));
  float eye=ink(len2(fabsf(x)-2.9f,yy-(top+3.0f))-0.95f,aa);
  c=paint(c,type==4?color(0.46f,0.80f,0.72f):color(0.83f,0.27f,0.13f),eye);
  if(type==0||type==3) {
   for(int k=0;k<3;k++){float rib=ink(segment(x,yy,-width*0.55f,-20.0f+(float)k*3.6f,width*0.55f,-18.0f+(float)k*3.6f)-0.8f,aa);c=paint(c,color(0.42f*shade,0.38f*shade,0.29f*shade),rib);}
  }
  if(type==2) {
   c=paint(c,color(0.44f,0.37f,0.23f),ink(segment(x,yy,18.0f,-1.0f,21.0f,-36.0f)-1.3f,aa));
   float light=len2(x-21.0f,yy+36.0f);c=paint(c,color(0.71f,0.43f,0.20f),expf(-light/8.0f)*0.65f);
   c=paint(c,color(0.97f,0.74f,0.39f),ink(light-2.5f,aa));
  }
  if(type==3){
   c=paint(c,color(0.18f,0.20f,0.19f),ink(len2((fabsf(x)-14.0f)*0.8f,yy+24.0f)-6.5f,aa));
   c=paint(c,color(0.52f,0.46f,0.32f),ink(segment(x,yy,-7.0f,-29.0f,-11.0f,-43.0f)-1.6f,aa));
   c=paint(c,color(0.52f,0.46f,0.32f),ink(segment(x,yy,7.0f,-29.0f,11.0f,-43.0f)-1.6f,aa));
  }
  if(type==4) {
   c=paint(c,color(0.60f,0.71f,0.66f),ink(segment(x,yy,-14.0f,-12.0f,-22.0f,6.0f)-1.1f,aa));
   c=paint(c,color(0.60f,0.71f,0.66f),ink(segment(x,yy,14.0f,-12.0f,22.0f,6.0f)-1.1f,aa));
  }
 }
 if(E[b+17]>0.0f){float flash=sat(E[b+17]/0.13f)*0.7f;c.x=mixf(c.x,0.96f,flash);c.y=mixf(c.y,0.86f,flash);c.z=mixf(c.z,0.64f,flash);}
 if(E[b+4]<E[b+5]*0.99f) {
  float hp=sat(E[b+4]/E[b+5]);float bar=ink(boxd(x,y-11.0f,13.0f,1.0f),aa);
  c=paint(c,color(0.13f,0.08f,0.07f),bar);if(x< -13.0f+26.0f*hp)c=paint(c,color(0.63f,0.20f,0.13f),bar);
 }
 return c;
}
__device__ float4 playerArt(float x,float y,const float* S,float aa) {
 if(fabsf(x)>58.0f||y< -62.0f||y>38.0f)return make_float4(0.0f,0.0f,0.0f,0.0f);
 float time=S[6];float walk=sinf(time*13.0f)*sat(len2(S[2],S[3])/130.0f);float yy=y+fabsf(walk)*1.0f;
 float4 c=make_float4(0.0f,0.0f,0.0f,0.0f);
 c=paint(c,color(0.16f,0.17f,0.16f),ink(segment(x,yy,-5.0f,-5.0f,-7.0f,4.0f+walk*3.0f)-3.0f,aa));
 c=paint(c,color(0.20f,0.20f,0.18f),ink(segment(x,yy,5.0f,-5.0f,7.0f,4.0f-walk*3.0f)-3.0f,aa));
 float cloak=fmaxf(fabsf(x+sinf(yy*0.2f+time*4.0f)*1.3f)-(10.5f+(yy+21.0f)*0.16f),fmaxf(-28.0f-yy,yy+2.0f));
 c=paint(c,color(0.15f,0.19f,0.20f),ink(cloak,aa));
 c=paint(c,color(0.26f,0.29f,0.27f),ink(segment(x,yy,-8.0f,-21.0f,-10.0f,-3.0f)-1.4f,aa));
 c=paint(c,color(0.11f,0.13f,0.13f),ink(boxd(x,yy+14.0f,6.0f,9.0f),aa));
 c=paint(c,color(0.58f,0.54f,0.40f),ink(segment(x,yy,-8.0f,-18.0f,5.0f,-5.0f)-1.0f,aa));
 c=paint(c,color(0.45f,0.48f,0.43f),ink(boxd(x+1.0f,yy+19.0f,2.3f,3.5f),aa));
 float hood=len2(x,yy+30.0f)-9.2f;c=paint(c,color(0.28f,0.32f,0.30f),ink(hood,aa));
 c=paint(c,color(0.049f,0.065f,0.069f),ink(len2(x-1.0f,yy+28.0f)-6.4f,aa));
 c=paint(c,color(0.74f,0.71f,0.60f),ink(boxd(x-1.0f,yy+27.0f,4.0f,3.5f),aa));
 c=paint(c,color(0.12f,0.16f,0.16f),ink(boxd(x-1.0f,yy+28.0f,4.4f,0.9f),aa));
 c=paint(c,color(0.47f,0.13f,0.10f),ink(segment(x,yy,-6.0f,-21.0f,8.0f,-22.0f)-2.0f,aa));
 c=paint(c,color(0.43f,0.12f,0.085f),ink(segment(x,yy,7.0f,-22.0f,14.0f+sinf(time*5.0f)*2.0f,-7.0f)-1.8f,aa));
 float ax=S[23];float ay=S[24];float sx=ax*9.0f;float sy=ay*9.0f-12.0f;
 c=paint(c,color(0.31f,0.33f,0.30f),ink(segment(x,yy,6.0f,-15.0f,sx,sy)-3.0f,aa));
 c=paint(c,color(0.66f,0.64f,0.53f),ink(segment(x,yy,sx,sy,sx+ax*17.0f,sy+ay*17.0f)-1.8f,aa));
 if(S[15]>0.28f/S[33]-0.055f) {
  float muzzle=len2(x-sx-ax*22.0f,yy-sy-ay*22.0f);c=paint(c,color(0.81f,0.46f,0.20f),expf(-muzzle/10.0f)*0.5f);
  c=paint(c,color(1.0f,0.92f,0.59f),ink(muzzle-3.0f,aa));
 }
 if(S[38]>0.0f&&frac(S[38]*16.0f)<0.5f){c.x=mixf(c.x,0.8f,0.35f);c.y*=0.7f;}
 return c;
}
__global__ void buildTiles(const float* S,const float* E,const float* P,int* Tiles,int width,int height) {
 int id=(int)(blockIdx.x*blockDim.x+threadIdx.x);int tw=(width+31)/32;int th=(height+31)/32;if(id>=tw*th)return;
 int b=id*TILE_CAP;int count=0;float cx=(float)(id%tw*TILE+TILE/2);float cy=(float)(id/tw*TILE+TILE/2);float zoom=(float)height/700.0f;
 float reach=42.0f*zoom+16.0f;
 // Living units first so a crowded tile drops corpses, not bodies.
 for(int i=0;i<ENEMIES;i++)if(E[i*ES+4]>0.0f){
  float sx=(E[i*ES]-S[25])*zoom+(float)width*0.5f;float sy=(E[i*ES+1]-S[26])*zoom+(float)height*0.5f;
  if(fabsf(sx-cx)<reach&&fabsf(sy-16.0f*zoom-cy)<reach+10.0f*zoom&&count<TILE_CAP-1){Tiles[b+1+count]=i;count++;}
 }
 for(int i=0;i<BULLETS;i++)if(P[i*BS+6]>0.0f){
  float sx=(P[i*BS]-S[25])*zoom+(float)width*0.5f;float sy=(P[i*BS+1]-S[26])*zoom+(float)height*0.5f;
  if(fabsf(sx-cx)<25.0f*zoom+16.0f&&fabsf(sy-cy)<25.0f*zoom+16.0f&&count<TILE_CAP-1){Tiles[b+1+count]=1000+i;count++;}
 }
 for(int i=0;i<ENEMIES;i++)if(E[i*ES+4]>0.0f&&E[i*ES+33]>0.0f){
  float sx=(E[i*ES+29]-S[25])*zoom+(float)width*0.5f;float sy=(E[i*ES+30]-S[26])*zoom+(float)height*0.5f;
  if(fabsf(sx-cx)<22.0f*zoom+16.0f&&fabsf(sy-cy)<22.0f*zoom+16.0f&&count<TILE_CAP-1){Tiles[b+1+count]=2000+i;count++;}
 }
 for(int i=0;i<ENEMIES;i++)if(E[i*ES+4]<0.0f){
  float sx=(E[i*ES]-S[25])*zoom+(float)width*0.5f;float sy=(E[i*ES+1]-S[26])*zoom+(float)height*0.5f;
  if(fabsf(sx-cx)<reach&&fabsf(sy-16.0f*zoom-cy)<reach+10.0f*zoom&&count<TILE_CAP-1){Tiles[b+1+count]=i;count++;}
 }
 Tiles[b]=count;
}
// Floor is a cheap pass of its own. A single fat kernel was dropping a
// screen-centered rectangle of dirt wherever the sprite list got long.
__global__ void renderGround(const float* S,unsigned int* Pixels,int width,int height) {
 int ix=(int)(blockIdx.x*blockDim.x+threadIdx.x);int iy=(int)(blockIdx.y*blockDim.y+threadIdx.y);if(ix>=width||iy>=height)return;
 float zoom=(float)height/700.0f;float aa=1.1f/zoom;float time=S[46];
 float wx=((float)ix-(float)width*0.5f)/zoom+S[25];float wy=((float)iy-(float)height*0.5f)/zoom+S[26];
 float pd=len2(wx-S[0],wy-S[1]);float radial=len2(wx,wy);
 float ground=noise2(wx*0.018f,wy*0.018f);float detail=noise2(wx*0.23f,wy*0.23f);
 float4 c=color(0.071f+ground*0.035f,0.091f+ground*0.041f,0.092f+ground*0.038f);
 float row=floorf(wy/33.0f);float tx=frac((wx+((row-floorf(row/2.0f)*2.0f))*28.0f)/57.0f);float ty=frac(wy/33.0f);
 float joint=fminf(fminf(tx,1.0f-tx)*57.0f,fminf(ty,1.0f-ty)*33.0f);
 float stoneNoise=h2(floorf((wx+(row-floorf(row/2.0f)*2.0f)*28.0f)/57.0f),row);
 float4 paving=color(0.13f+stoneNoise*0.028f,0.151f+stoneNoise*0.033f,0.149f+stoneNoise*0.035f);
 paving=paving*(0.65f+detail*0.43f);paving=blend(color(0.042f,0.052f,0.052f),paving,smooth01(0.0f,1.4f,joint));
 float stone=1.0f;
 if(radial>230.0f){
  float broken=smooth01(0.90f,0.97f,stoneNoise);
  float mud=smooth01(0.88f,0.97f,noise2(wx*0.05f+3.1f,wy*0.05f));
  stone=1.0f-fmaxf(broken,mud*0.35f);
 }
 c=blend(c,paving,stone);
 float crack=fabsf(noise2(wx*0.055f,wy*0.055f)-0.5f);c=blend(c,color(0.043f,0.050f,0.047f),ink(crack-0.008f,0.007f)*stone*0.65f);
 float blade=frac(wx*0.19f+floorf(wy*0.25f)*0.74f);float grass=ink(fabsf(blade-0.5f)-0.07f,0.07f)*smooth01(0.60f,0.83f,detail)*(1.0f-stone);
 c=blend(c,color(0.17f,0.185f,0.13f),grass*0.65f);
 float puddle=smooth01(0.65f,0.85f,noise2(wx*0.028f+4.0f,wy*0.033f));float glint=sat(sinf(wx*0.14f+wy*0.07f+time*1.8f))*puddle;
 c=blend(c,color(0.17f,0.21f,0.22f),puddle*0.16f+glint*0.07f);
 // Boundary stone and wrought-iron fence make the play area legible.
 float wall=fminf(fabsf(fabsf(wx)-1620.0f),fabsf(fabsf(wy)-1620.0f));
 if(wall<15.0f){float along=fabsf(fabsf(wx)-1620.0f)<fabsf(fabsf(wy)-1620.0f)?wy:wx;float post=fabsf(frac(along/23.0f)-0.5f)*23.0f;float iron=fminf(fmaxf(wall-2.0f,post-1.1f),fabsf(wall-8.0f)-1.2f);c=blend(c,color(0.31f,0.30f,0.25f),ink(iron,aa));}
 if(fabsf(wx)>1627.0f||fabsf(wy)>1627.0f)c=c*0.22f;
 // The central seal is actual procedural engraving in world coordinates.
 float ring=fminf(fabsf(radial-94.0f),fminf(fabsf(radial-177.0f),fabsf(radial-184.0f)));
 c=blend(c,color(0.29f,0.25f,0.18f),ink(ring-0.8f,aa)*0.6f);
 float angle=atan2f(wy,wx);float spokes=fabsf(sinf(angle*12.0f));
 if(radial>149.0f&&radial<172.0f)c=blend(c,color(0.24f,0.22f,0.16f),ink(spokes-0.04f,0.03f)*0.7f);
 float cross=fminf(segment(wx,wy,-64.0f,-46.0f,64.0f,46.0f),segment(wx,wy,-64.0f,46.0f,64.0f,-46.0f));
 if(radial<80.0f)c=blend(c,color(0.23f,0.21f,0.16f),ink(cross-0.8f,aa));
 float moon=0.80f+0.12f*noise2(wx*0.003f+time*0.015f,wy*0.003f);float lamplight=0.75f*expf(-pd/230.0f);
 c=c*(moon+lamplight);
 // Warm fire pools. Their light is computed from actual world positions.
 for(int k=0;k<4;k++) {
  float fx=k%2==0?-214.0f:214.0f;float fy=k<2?-144.0f:144.0f;float dx=wx-fx;float dy=wy-fy;
  float d=len2(dx,dy);float flame=(0.90f+0.10f*sinf(time*13.0f+(float)k));float glow=expf(-d/100.0f)*flame;
  c.x+=glow*0.14f;c.y+=glow*0.075f;c.z+=glow*0.018f;
 }
 // Player slash, ward, and orbiting blades are drawn in the same CUDA image.
 if(S[21]>0.0f){float r=(0.55f-S[21])*440.0f+25.0f;float edge=expf(-fabsf(pd-r)/3.0f)*S[21]*1.7f;c.x+=edge*0.32f;c.y+=edge*0.47f;c.z+=edge*0.45f;}
 if(S[18]>0.0f&&pd<120.0f){float a=atan2f(wy-S[1],wx-S[0])-atan2f(S[24],S[23]);float arc=cosf(a+(S[18]/0.24f-0.5f)*1.5f);
  float slash=expf(-fabsf(pd-84.0f)/3.0f)*sat((arc-0.15f)*2.0f)*S[18]*3.8f;c.x+=slash*0.65f;c.y+=slash*0.71f;c.z+=slash*0.64f;}
 if(S[14]>0.0f){float trail=expf(-segment(wx,wy,S[0],S[1],S[0]-S[2]*0.08f,S[1]-S[3]*0.08f)/10.0f)*0.33f;c.x+=trail*0.25f;c.y+=trail*0.50f;c.z+=trail*0.50f;}
 Pixels[iy*width+ix]=rgba(c);
}
__global__ void renderWorld(const float* S,const float* E,const float* P,const int* Tiles,unsigned int* Pixels,int width,int height) {
 int ix=(int)(blockIdx.x*blockDim.x+threadIdx.x);int iy=(int)(blockIdx.y*blockDim.y+threadIdx.y);if(ix>=width||iy>=height)return;
 float zoom=(float)height/700.0f;float aa=1.1f/zoom;float time=S[46];float gameTime=S[6];
 float wx=((float)ix-(float)width*0.5f)/zoom+S[25];float wy=((float)iy-(float)height*0.5f)/zoom+S[26];
 float4 c=unrgba(Pixels[iy*width+ix]);
 float depth=-100000.0f;float4 front=make_float4(0.0f,0.0f,0.0f,0.0f);
 // Static scenery: carved headstones and broken columns, matching collision geometry.
 float gx=floorf((wx+96.0f)/192.0f);float gy=floorf((wy+96.0f)/192.0f);
 float ox=gx*192.0f+(h2(gx,gy)-0.5f)*60.0f;float oy=gy*192.0f+(h2(gy,gx+31.0f)-0.5f)*50.0f;
 if(len2(ox,oy)>235.0f&&h2(gx+82.0f,gy)>=0.35f){
  float x=wx-ox;float y=wy-oy;float shadow=expf(-len2((x-9.0f)/1.7f,(y-9.0f)/0.6f)/14.0f)*0.55f;c=c*(1.0f-shadow);
  float kind=h2(gx+83.0f,gy+49.0f);
  float d=fminf(boxd(x,y+16.0f,14.0f,18.0f),len2(x,y+34.0f)-14.0f);
  if(kind>0.64f)d=fminf(boxd(x,y+25.0f,5.5f,28.0f),boxd(x,y+36.0f,18.0f,5.0f));
  else if(kind>0.36f){d=boxd(x,y+23.0f,10.0f,25.0f);d=fmaxf(d,-(x+y+47.0f)*0.70f);}
  float4 prop=color(0.28f,0.30f,0.27f);float pat=noise2(wx*0.22f,wy*0.22f);prop=prop*(0.7f+pat*0.32f+sat(-x/18.0f)*0.16f);
  float border=ink(fabsf(d+2.0f)-0.7f,aa);prop=blend(prop,color(0.40f,0.41f,0.34f),border*0.6f);
  float cut=fminf(segment(x,y,0.0f,-34.0f,0.0f,-13.0f),segment(x,y,-6.0f,-27.0f,6.0f,-27.0f));prop=blend(prop,color(0.11f,0.13f,0.12f),ink(cut-1.0f,aa));
  float base=boxd(x,y,19.0f,5.0f);if(base<d){d=base;prop=color(0.20f,0.23f,0.21f);}
  // Sort by the southern foot so the runner is not buried under the headstone.
  float4 stoneSprite=make_float4(prop.x,prop.y,prop.z,ink(d,aa));
  if(stoneSprite.w>0.004f){if(oy+8.0f>=depth){c=blend(c,color(front.x,front.y,front.z),front.w);front=stoneSprite;depth=oy+8.0f;}else c=blend(c,color(stoneSprite.x,stoneSprite.y,stoneSprite.z),stoneSprite.w);}
 }
 int tile=((iy/TILE)*((width+TILE-1)/TILE)+ix/TILE)*TILE_CAP;int count=Tiles[tile];
 if(count<0||count>TILE_CAP-1)count=0;
 float shade=0.0f;
 for(int j=0;j<count;j++)if(Tiles[tile+1+j]<1000){
  int b=Tiles[tile+1+j]*ES;float x=wx-E[b];float y=wy-E[b+1];
  if(E[b+4]<0.0f){
   float4 sprite=enemyArt(x,y,E,b,gameTime,aa);
   c=blend(c,color(sprite.x,sprite.y,sprite.z),sprite.w);
  }else{
   shade=fmaxf(shade,expf(-len2(x/1.5f,y/0.55f)/12.0f)*0.28f);
   if(E[b+8]==4.0f){
    float r=E[b+6]==3.0f?36.0f:27.0f;float ring=fabsf(len2(x,y*1.2f)-r)-1.2f;
    c=blend(c,color(0.73f,0.25f,0.12f),ink(ring,aa)*0.55f);
   }
   float4 sprite=enemyArt(x,y,E,b,gameTime,aa);
   if(sprite.w>0.004f){if(E[b+1]>=depth){c=blend(c,color(front.x,front.y,front.z),front.w);front=sprite;depth=E[b+1];}else c=blend(c,color(sprite.x,sprite.y,sprite.z),sprite.w);}
  }
 }
 c=c*(1.0f-shade);
 float pshadow=expf(-len2((wx-S[0])/1.45f,(wy-S[1])/0.55f)/12.0f)*0.38f;c=c*(1.0f-pshadow);
 float4 player=playerArt(wx-S[0],wy-S[1],S,aa);
 if(player.w>0.004f){if(S[1]>=depth){c=blend(c,color(front.x,front.y,front.z),front.w);front=player;depth=S[1];}else c=blend(c,color(player.x,player.y,player.z),player.w);}
 // Braziers behind the current winner stay on the ground; the winner is applied next.
 for(int k=0;k<4;k++) {
  float fx=k%2==0?-214.0f:214.0f;float fy=k<2?-144.0f:144.0f;float x=wx-fx;float y=wy-fy;
  if(fabsf(x)<23.0f&&fabsf(y)<55.0f&&fy+10.0f<depth){
   c=blend(c,color(0.23f,0.22f,0.17f),ink(boxd(x,y+9.0f,3.0f,11.0f),aa));
   c=blend(c,color(0.38f,0.31f,0.20f),ink(boxd(x,y+22.0f,8.0f,3.0f),aa));
   float fire=len2((x-sinf(time*8.0f+y*0.25f)*1.2f)/0.65f,(y+31.0f)*0.8f)-7.0f;
   c=blend(c,color(0.94f,0.46f,0.13f),ink(fire,aa));c=blend(c,color(1.0f,0.86f,0.46f),ink(fire+3.0f,aa));
  }
 }
 c=blend(c,color(front.x,front.y,front.z),front.w);
 // Tiny brazier geometry, flame and sparks; emissive shapes remain readable in shadow.
 for(int k=0;k<4;k++) {
  float fx=k%2==0?-214.0f:214.0f;float fy=k<2?-144.0f:144.0f;float x=wx-fx;float y=wy-fy;
  if(fabsf(x)<23.0f&&fabsf(y)<55.0f&&fy+10.0f>=depth){
   c=blend(c,color(0.23f,0.22f,0.17f),ink(boxd(x,y+9.0f,3.0f,11.0f),aa));
   c=blend(c,color(0.38f,0.31f,0.20f),ink(boxd(x,y+22.0f,8.0f,3.0f),aa));
   float fire=len2((x-sinf(time*8.0f+y*0.25f)*1.2f)/0.65f,(y+31.0f)*0.8f)-7.0f;
   c=blend(c,color(0.94f,0.46f,0.13f),ink(fire,aa));c=blend(c,color(1.0f,0.86f,0.46f),ink(fire+3.0f,aa));
  }
 }
 // Projectile trails use the same bounded spatial tile list as the creatures.
 for(int j=0;j<count;j++){
  int id=Tiles[tile+1+j];
  if(id>=1000&&id<2000){int b=(id-1000)*BS;
   float d=segment(wx,wy,P[b],P[b+1],P[b]-P[b+4]*0.024f,P[b+1]-P[b+5]*0.024f);float a=expf(-d/2.0f);
   c.x+=a*0.9f;c.y+=a*0.72f;c.z+=a*0.38f;
  }
  if(id>=2000){int b=(id-2000)*ES;float d=len2(wx-E[b+29],wy-E[b+30]);float a=expf(-d/4.0f);c.x+=a*0.8f;c.y+=a*0.29f;c.z+=a*0.10f;}
 }
 for(int k=0;k<5;k++)if((float)k<S[37]){
  float a=gameTime*2.2f+(float)k*PI*2.0f/S[37];float dx=wx-S[0]-cosf(a)*78.0f;float dy=wy-S[1]-sinf(a)*78.0f;
  float knife=segment(dx,dy,-cosf(a)*9.0f,-sinf(a)*9.0f,cosf(a)*9.0f,sinf(a)*9.0f);c=blend(c,color(0.81f,0.83f,0.72f),ink(knife-1.2f,aa));
 }
 // Slow ground mist, rain and restrained grain; intentionally no neon debug palette.
 float mist=noise2(wx*0.006f+time*0.025f,wy*0.008f-time*0.012f);float fog=smooth01(0.46f,0.91f,mist)*0.13f;
 c=blend(c,color(0.34f,0.38f,0.37f),fog);
 // Screen/world Y increases downward, so subtracting time moves drops down the frame.
 float rainX=wx*0.13f-wy*0.035f;float rainY=wy*0.04f-time*16.0f;float cell=h2(floorf(rainX),floorf(rainY));
 float rain=ink(fabsf(frac(rainX)-0.5f)-0.018f,0.028f)*powf(1.0f-frac(rainY),1.65f)*0.14f;
 if(cell>0.78f)c=c+color(rain*0.85f,rain,rain);
 float nx=((float)ix/(float)width-0.5f)*2.0f;float ny=((float)iy/(float)height-0.5f)*2.0f;float vignette=1.0f-0.25f*powf(sat((nx*nx+ny*ny)*0.48f),1.3f);
 c=c*vignette;float grain=(h2((float)ix+floorf(time*12.0f),(float)iy)-0.5f)*0.013f;c.x+=grain;c.y+=grain;c.z+=grain;
 if(S[4]<35.0f&&S[8]==1.0f){float danger=(1.0f-S[4]/35.0f)*sat((nx*nx+ny*ny)*0.45f);c=blend(c,color(0.30f,0.038f,0.027f),danger*0.45f);}
 Pixels[iy*width+ix]=rgba(c);
}
