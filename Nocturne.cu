// NOCTURNE / generated single-file CUDA source.
// Rebuild from kernels/*.cu with npm run build. See docs/ARCHITECTURE.md for dispatch order.

// ===== COMMON =====
// NOCTURNE / shared CUDA helpers. Maintained source, not a WGSL wrapper.
#define ENEMIES 320
#define ES 48
#define BULLETS 128
#define BS 10
#define REPLAY 4096
#define RS 28
#define INPUTS 16
#define HIDDEN 32
#define PARAMS 610
#define BATCH 32
#define WS 88
#define PI 3.14159265359f
__device__ float sat(float x) { return fminf(1.0f, fmaxf(0.0f, x)); }
__device__ float mixf(float a, float b, float t) { return a + (b-a)*t; }
__device__ float len2(float x, float y) { return sqrtf(x*x+y*y); }
__device__ float frac(float x) { return x-floorf(x); }
__device__ float hashf(float n) { return frac(sinf(n*127.1f+311.7f)*43758.5453f); }
__device__ float h2(float x,float y) { return hashf(x*13.37f+y*71.91f); }
__device__ float smooth01(float a,float b,float x) { float t=sat((x-a)/(b-a)); return t*t*(3.0f-2.0f*t); }
__device__ float noise2(float x,float y) {
 float ix=floorf(x); float iy=floorf(y); float fx=frac(x); float fy=frac(y);
 fx=fx*fx*(3.0f-2.0f*fx);fy=fy*fy*(3.0f-2.0f*fy);
 return mixf(mixf(h2(ix,iy),h2(ix+1.0f,iy),fx),mixf(h2(ix,iy+1.0f),h2(ix+1.0f,iy+1.0f),fx),fy);
}
__device__ float boxd(float x,float y,float bx,float by) {
 float qx=fabsf(x)-bx;float qy=fabsf(y)-by;
 return len2(fmaxf(qx,0.0f),fmaxf(qy,0.0f))+fminf(fmaxf(qx,qy),0.0f);
}
__device__ float segment(float x,float y,float ax,float ay,float bx,float by) {
 float vx=bx-ax;float vy=by-ay;float t=sat(((x-ax)*vx+(y-ay)*vy)/(vx*vx+vy*vy+0.0001f));
 return len2(x-ax-vx*t,y-ay-vy*t);
}
__device__ float obstacle(float x,float y) {
 float gx=floorf((x+96.0f)/192.0f); float gy=floorf((y+96.0f)/192.0f);
 float cx=gx*192.0f+(h2(gx,gy)-0.5f)*60.0f;float cy=gy*192.0f+(h2(gy,gx+31.0f)-0.5f)*50.0f;
 if(len2(cx,cy)<235.0f || h2(gx+82.0f,gy)<0.35f) return 1000.0f;
 return boxd(x-cx,y-cy,18.0f,11.0f);
}
__device__ float4 color(float r,float g,float b) { return make_float4(r,g,b,1.0f); }
__device__ float4 blend(float4 a,float4 b,float t) { return a+(b-a)*sat(t); }
__device__ float ink(float d,float aa) { return sat(0.5f-d/aa); }
__device__ unsigned int rgba(float4 c) {
 unsigned int r=(unsigned int)(sat(c.x)*255.0f);unsigned int g=(unsigned int)(sat(c.y)*255.0f);unsigned int b=(unsigned int)(sat(c.z)*255.0f);
 return r | (g<<8) | (b<<16) | 4278190080u;
}
__device__ float4 unrgba(unsigned int c) { return make_float4((float)(c&255u)/255.0f,(float)((c>>8)&255u)/255.0f,(float)((c>>16)&255u)/255.0f,1.0f); }

// ===== GAME =====
// All state transitions, rules, collision, progression and enemy decisions live here.
__global__ void initialise(float* S,float* W,float* M,float* V,float* G,float* Brain,int seed) {
 int i=(int)(blockIdx.x*blockDim.x+threadIdx.x);
 if(i<128) S[i]=0.0f;
 if(i<PARAMS) { W[i]=i>=544?0.0f:(hashf((float)(i+seed))-0.5f)*0.10f;M[i]=0.0f;V[i]=0.0f; }
 if(i<640) {
  int field=i%16;int variant=i/16;float v=0.0f;
  if(field<6) v=0.2f+0.6f*hashf((float)(i+seed*3));
  if(field==8) v=1.0f;
  G[i]=v;
 }
 if(i<32) Brain[i]=0.0f;
 // No cross-thread reads. Initial run values are assigned by a separate dispatch.
}
__global__ void newRun(float* S,int seed) {
 if(threadIdx.x!=0 || blockIdx.x!=0) return;
 S[4]=100.0f;S[5]=100.0f;S[10]=1.0f;S[11]=14.0f;S[23]=1.0f;
 S[31]=1.0f;S[32]=20.0f;S[33]=1.0f;S[34]=1.0f;S[35]=1.0f;S[36]=85.0f;
 S[45]=1.0f;S[48]=(float)seed;S[49]=1.0f;
}
__global__ void stepWorld(float* S,float* E,const float* I,float* G,float aspect,float dt) {
 if(threadIdx.x!=0 || blockIdx.x!=0) return;
 S[46]+=dt;S[49]=0.0f;S[44]=0.0f;S[30]=0.0f;S[51]=0.0f;S[61]=0.0f;
 int mode=(int)S[8];
 bool click=I[4]>0.5f&&S[64]<0.5f;
 S[64]=I[4];
 bool start=(I[8]>0.5f && S[68]<0.5f)||(mode==0&&click);
 bool pause=I[9]>0.5f && S[69]<0.5f;
 bool aut=I[11]>0.5f && S[71]<0.5f;
 bool restart=I[12]>0.5f && S[72]<0.5f;
 bool learning=I[13]>0.5f && S[73]<0.5f;
 S[68]=I[8];S[69]=I[9];S[71]=I[11];S[72]=I[12];S[73]=I[13];
 if(I[14]>0.5f&&S[74]<0.5f)S[47]=1.0f-S[47];S[74]=I[14];
 if((mode==0 && start)||((mode==4||mode==5)&&(start||restart))) {
  float seed=S[48]+79.0f;float learn=S[45];float anim=S[46];
  for(int j=0;j<64;j++) S[j]=0.0f;
  S[48]=seed;S[46]=anim;S[4]=100.0f;S[5]=100.0f;S[10]=1.0f;S[11]=14.0f;S[23]=1.0f;
  S[31]=1.0f;S[32]=20.0f;S[33]=1.0f;S[34]=1.0f;S[35]=1.0f;S[36]=85.0f;S[45]=learn;
  S[8]=1.0f;S[49]=1.0f;return;
 }
 if((pause||(start&&mode==2))&&(mode==1||mode==2)) {S[8]=mode==1?2.0f:1.0f;return;}
 if(learning) S[45]=1.0f-S[45];
 if(aut) S[31]=1.0f-S[31];
 if(mode==3) {
  int choice=(int)I[10]-1;
  if(click){
   float vw=aspect*720.0f;float mx=(I[2]+1.0f)*vw*0.5f;float my=(I[3]+1.0f)*360.0f;
   for(int k=0;k<3;k++){float bx=vw<850.0f?vw*0.5f:vw*0.5f+(float)(k-1)*280.0f;float by=vw<850.0f?282.0f+(float)k*133.0f:390.0f;
    float ww=vw<850.0f?vw-40.0f:254.0f;float hh=vw<850.0f?116.0f:234.0f;if(fabsf(mx-bx)<ww*0.5f&&fabsf(my-by)<hh*0.5f)choice=k;}
  }
  if(choice>=0&&choice<3) {
   int upgrade=((int)S[10]*3+choice)%6;
   if(upgrade==0) S[32]*=1.22f;
   if(upgrade==1) S[33]=fminf(2.7f,S[33]*1.17f);
   if(upgrade==2) {S[5]+=25.0f;S[4]=fminf(S[5],S[4]+55.0f);}
   if(upgrade==3) {S[35]=fminf(5.0f,S[35]+1.0f);S[32]*=0.94f;}
   if(upgrade==4) {S[37]=fminf(5.0f,S[37]+1.0f);S[36]+=25.0f;}
   if(upgrade==5) {S[34]=fminf(1.55f,S[34]*1.08f);S[20]=0.0f;S[4]=fminf(S[5],S[4]+25.0f);}
   S[8]=1.0f;
  }
  return;
 }
 if(mode!=1) return;
 S[61]=1.0f; // Acknowledge last-step events even when this step opens a relic menu.
 float damage=0.0f;float nearest=100000.0f;float nx=1.0f;float ny=0.0f;int alive=0;
 for(int j=0;j<ENEMIES;j++) {
  int b=j*ES;
  if(E[b+4]>0.0f) {alive++;float dx=E[b]-S[0];float dy=E[b+1]-S[1];float dd=dx*dx+dy*dy;if(dd<nearest){nearest=dd;nx=dx;ny=dy;}}
  damage+=E[b+20];S[9]+=E[b+21];
  if(E[b+21]>0.0f) S[55]+=1.0f;
  if(E[b+19]>0.0f) {
   S[12]+=1.0f;S[39]+=1.0f;S[40]=2.5f;
   int gb=(int)E[b+13]*16;
   // Fitness observes real survival, damage and proximity; raw speed/HP are not genes.
   float fit=fminf(E[b+23],30.0f)*0.07f+fminf(E[b+22],12.0f)*0.07f+fminf(E[b+7],25.0f)*0.012f;
   if(E[b+24]==G[gb+8]){G[gb+6]=mixf(G[gb+6],fit,0.18f);G[gb+7]+=1.0f;int cause=(int)E[b+46];if(cause>=1&&cause<=4)G[gb+9+cause]+=1.0f;}
  }
 }
 S[27]=(float)alive;
 if(damage>0.0f&&S[38]<=0.0f&&S[14]<=0.0f) {
  float accepted=fminf(fminf(22.0f,damage),S[4]);S[4]-=accepted;S[38]=0.55f;S[54]+=1.0f;
  // Credit only health actually removed, including the aggregate hit cap and invulnerability.
  for(int j=0;j<ENEMIES;j++)if(E[j*ES+20]>0.0f)E[j*ES+23]+=accepted*E[j*ES+20]/damage;
 }
 if(S[4]<=0.0f) {S[4]=0.0f;S[8]=4.0f;S[58]+=1.0f;return;}
 if(S[6]>=600.0f) {S[8]=5.0f;return;}
 if(S[9]>=S[11]) {S[9]-=S[11];S[10]+=1.0f;S[11]=14.0f+S[10]*9.0f;S[8]=3.0f;S[56]+=1.0f;return;}
 S[51]=1.0f;S[7]+=1.0f;S[6]+=dt;S[50]=floorf(S[6]/30.0f)+1.0f;
 S[13]=fmaxf(0.0f,S[13]-dt);S[14]=fmaxf(0.0f,S[14]-dt);S[15]=fmaxf(0.0f,S[15]-dt);
 S[17]=fmaxf(0.0f,S[17]-dt);S[18]=fmaxf(0.0f,S[18]-dt);S[20]=fmaxf(0.0f,S[20]-dt);S[21]=fmaxf(0.0f,S[21]-dt);
 S[38]=fmaxf(0.0f,S[38]-dt);S[40]=fmaxf(0.0f,S[40]-dt);if(S[40]<=0.0f) S[39]=0.0f;
 float mx=I[0];float my=I[1];float ml=len2(mx,my);if(ml>1.0f){mx/=ml;my/=ml;}
 float ax=I[2]*aspect*350.0f+S[25]-S[0];float ay=I[3]*350.0f+S[26]-S[1];
 if(I[4]<0.5f&&S[31]>0.5f&&alive>0) {ax=nx;ay=ny;}
 float al=fmaxf(0.01f,len2(ax,ay));S[23]=ax/al;S[24]=ay/al;
 if(I[6]>0.5f&&S[13]<=0.0f) {S[14]=0.18f;S[13]=2.1f;S[57]+=1.0f;S[59]=ml<0.1f?S[23]:mx;S[60]=ml<0.1f?S[24]:my;}
 if(S[14]>0.0f){mx=S[59];my=S[60];}
 float speed=158.0f*S[34];if(S[14]>0.0f) speed*=3.7f;
 S[2]=mx*speed;S[3]=my*speed;
 float oldX=S[0];float oldY=S[1];
 float px=S[0]+S[2]*dt;float py=S[1]+S[3]*dt;
 if(obstacle(px,S[1])>10.0f)S[0]=px;
 if(obstacle(S[0],py)>10.0f)S[1]=py;
 S[0]=fmaxf(-1600.0f,fminf(1600.0f,S[0]));S[1]=fmaxf(-1600.0f,fminf(1600.0f,S[1]));
 S[2]=(S[0]-oldX)/dt;S[3]=(S[1]-oldY)/dt;
 S[25]=mixf(S[25],S[0],1.0f-expf(-dt*9.0f));S[26]=mixf(S[26],S[1],1.0f-expf(-dt*9.0f));
 if((I[4]>0.5f||S[31]>0.5f)&&S[15]<=0.0f&&(alive>0||I[4]>0.5f)) {S[15]=0.28f/S[33];S[16]+=1.0f;S[44]=1.0f;S[52]+=1.0f;}
 if(I[5]>0.5f&&S[17]<=0.0f) {S[17]=0.95f;S[18]=0.24f;S[19]+=1.0f;S[53]+=1.0f;}
 if(I[7]>0.5f&&S[20]<=0.0f) {S[20]=7.0f;S[21]=0.55f;S[22]+=1.0f;}
 if(((int)S[7])%18==0) {
  int wanted=18+(int)(S[6]*0.28f);wanted= wanted>230?230:wanted;
  if(alive<wanted) {S[29]=S[28];S[30]=fminf(5.0f,(float)(wanted-alive));S[28]+=S[30];}
 }
}
__global__ void stepProjectiles(const float* S,float* P,float dt) {
 int i=(int)(blockIdx.x*blockDim.x+threadIdx.x);if(i>=BULLETS)return;int b=i*BS;
 if(S[49]>0.5f){for(int j=0;j<BS;j++) P[b+j]=0.0f;return;}
 if(S[8]!=1.0f||S[51]<0.5f)return;
 P[b+2]=P[b];P[b+3]=P[b+1];P[b]+=P[b+4]*dt;P[b+1]+=P[b+5]*dt;P[b+6]=fmaxf(0.0f,P[b+6]-dt);
 int pellets=(int)S[35];int serial=(int)S[16];
 for(int j=0;j<5;j++) {
  if(j<pellets&&S[44]>0.5f&&i==(serial*5+j)%BULLETS) {
   float angle=((float)j-((float)pellets-1.0f)*0.5f)*0.12f;float c=cosf(angle);float si=sinf(angle);
   float dx=S[23]*c-S[24]*si;float dy=S[23]*si+S[24]*c;
   P[b]=S[0]+dx*17.0f;P[b+1]=S[1]+dy*17.0f-5.0f;P[b+2]=P[b];P[b+3]=P[b+1];
   P[b+4]=dx*580.0f;P[b+5]=dy*580.0f;P[b+6]=0.85f;P[b+7]=S[32];P[b+8]=(float)(serial*5+j+1);P[b+9]=3.5f;
  }
 }
}
__global__ void stepEnemies(const float* S,const float* Old,float* E,const float* P,const float* G,const float* Brain,float dt,float aspect) {
 int i=(int)(blockIdx.x*blockDim.x+threadIdx.x);if(i>=ENEMIES)return;int b=i*ES;
 for(int j=0;j<ES;j++) E[b+j]=Old[b+j];
 if(S[49]>0.5f){for(int j=0;j<ES;j++)E[b+j]=0.0f;return;}
 if(S[61]>0.5f){E[b+19]=0.0f;E[b+20]=0.0f;E[b+21]=0.0f;}
 if(S[8]!=1.0f||S[51]<0.5f)return;
 float px=S[0];float py=S[1];float ex=Old[b];float ey=Old[b+1];float hp=Old[b+4];
 if(hp<=0.0f) {
  if(hp<0.0f) {
   E[b+18]+=dt;float dx=px-ex;float dy=py-ey;float dist=fmaxf(1.0f,len2(dx,dy));
   if(E[b+38]>0.0f&&dist<S[36]+40.0f) {E[b]+=dx/dist*260.0f*dt;E[b+1]+=dy/dist*260.0f*dt;}
   if(E[b+38]>0.0f&&dist<22.0f){E[b+21]=E[b+38];E[b+38]=0.0f;}
   if(E[b+18]>16.0f||(E[b+38]<=0.0f&&E[b+18]>3.0f))E[b+4]=0.0f;
  }
  for(int j=0;j<5;j++) {
   int serial=(int)S[29]+j;
   if(j<(int)S[30]&&serial%ENEMIES==i&&E[b+4]==0.0f) {
    float seed=(float)serial+S[48]*11.0f;float angle=hashf(seed)*PI*2.0f;
    // Always outside the visible player region, including ultrawide windows.
    float edge=fmaxf(fabsf(cosf(angle))/fmaxf(0.1f,aspect),fabsf(sinf(angle)));
    float radius=380.0f/fmaxf(0.10f,edge)+40.0f*hashf(seed+2.0f);
    float x=px+cosf(angle)*radius;float y=py+sinf(angle)*radius;
    int type=(int)(hashf(seed+3.0f)*5.0f);if(S[6]<12.0f)type=0;
    float health=35.0f+S[6]*0.10f;if(type==1)health*=0.75f;if(type==3)health*=3.2f;
    bool elite=serial>0&&serial%110==0;if(elite){type=3;health*=4.0f;}
    for(int k=0;k<ES;k++)E[b+k]=0.0f;
    E[b]=x;E[b+1]=y;E[b+4]=health;E[b+5]=health;E[b+6]=(float)type;
    E[b+12]=hashf(seed+7.0f)*6.28f;E[b+13]=(float)(type*8+serial%8);
    E[b+14]=-1.0f;E[b+15]=S[19];E[b+16]=S[22];E[b+24]=G[(type*8+serial%8)*16+8];
    for(int k=0;k<6;k++)E[b+40+k]=G[(type*8+serial%8)*16+k];
    E[b+35]=elite?1.0f:0.0f;E[b+36]=(float)serial;E[b+37]=seed;E[b+10]=1.0f;
   }
  }
  return;
 }
 int type=(int)Old[b+6];int gb=(int)Old[b+13]*16;
 float dx=px-ex;float dy=py-ey;float dist=fmaxf(0.001f,len2(dx,dy));float ux=dx/dist;float uy=dy/dist;
 float radius=type==3?18.0f:11.0f;if(Old[b+35]>0.5f)radius*=1.5f;
 E[b+7]+=dt;E[b+9]-=dt;E[b+10]-=dt;E[b+17]=fmaxf(0.0f,Old[b+17]-dt);E[b+11]=fmaxf(0.0f,Old[b+11]-dt*0.11f);
 if(dist<170.0f)E[b+22]+=dt;
 float dealt=0.0f;float cause=0.0f;
 for(int j=0;j<BULLETS;j++) {
  int q=j*BS;
  if(P[q+6]>0.0f&&P[q+8]>Old[b+14]&&fabsf(P[q]-ex)<35.0f&&fabsf(P[q+1]-ey)<35.0f) {
   if(segment(ex,ey,P[q+2],P[q+3],P[q],P[q+1])<radius+P[q+9]) {dealt+=P[q+7];cause=1.0f;E[b+14]=fmaxf(E[b+14],P[q+8]);}
  }
 }
 float facing=(-ux*S[23]-uy*S[24]);
 if(S[18]>0.0f&&S[19]!=Old[b+15]&&dist<112.0f&&facing>-0.2f) {dealt+=S[32]*2.0f;cause=2.0f;E[b+15]=S[19];}
 if(S[21]>0.0f&&S[22]!=Old[b+16]&&dist<(0.55f-S[21])*440.0f+25.0f) {dealt+=S[32]*2.8f;cause=3.0f;E[b+16]=S[22];E[b+11]=1.0f;}
 if(S[37]>0.0f&&E[b+17]<=0.0f) {
  for(int k=0;k<5;k++)if((float)k<S[37]) {
   float a=S[6]*2.2f+(float)k*PI*2.0f/S[37];float ox=px+cosf(a)*78.0f;float oy=py+sinf(a)*78.0f;
   if(len2(ex-ox,ey-oy)<radius+11.0f){dealt+=S[32]*0.65f;cause=4.0f;}
  }
 }
 if(dealt>0.0f){hp-=dealt;E[b+17]=0.13f;E[b+11]=fminf(1.0f,E[b+11]+0.25f);E[b+25]=-ux*110.0f;E[b+26]=-uy*110.0f;}
 if(hp<=0.0f){E[b+4]=-1.0f;E[b+19]=1.0f;E[b+46]=cause;E[b+38]=Old[b+35]>0.5f?25.0f:(type==3?6.0f:3.0f);E[b+18]=0.0f;E[b+33]=0.0f;return;}
 E[b+4]=hp;
 float trust=Brain[4];float lx=mixf(fmaxf(-210.0f,fminf(210.0f,S[2]*0.5f)),Brain[8]*140.0f,trust);float ly=mixf(fmaxf(-210.0f,fminf(210.0f,S[3]*0.5f)),Brain[9]*140.0f,trust);
 float tx=px+lx*Old[b+40]*1.7f;float ty=py+ly*Old[b+40]*1.7f;
 float orbit=Old[b+12]<PI?-1.0f:1.0f;
 int state=(int)Old[b+8];
 if(E[b+9]<=0.0f&&state<4) {
  float r=hashf(Old[b+37]+floorf(S[6]*3.0f));state=0;
  if(dist>80.0f&&r<Old[b+41])state=1;
  if(dist>190.0f&&r>0.89f+Old[b+45]*0.08f-Old[b+43]*0.06f)state=2;
  if(hp<Old[b+5]*0.40f&&r<Old[b+43])state=3;
  E[b+9]=0.22f+0.38f*hashf(Old[b+37]+S[7]);
 }
 float speed=69.0f;if(type==1)speed=113.0f;if(type==2)speed=65.0f;if(type==3)speed=49.0f;if(type==4)speed=93.0f;
 speed*=1.0f+fminf(0.28f,S[6]/1600.0f);
 float vx=0.0f;float vy=0.0f;
 if(state==1) {tx+=-uy*orbit*(60.0f+Old[b+41]*90.0f);ty+=ux*orbit*(60.0f+Old[b+41]*90.0f);}
 float td=fmaxf(1.0f,len2(tx-ex,ty-ey));vx=(tx-ex)/td*speed;vy=(ty-ey)/td*speed;
 if(state==2){vx=0.0f;vy=0.0f;}
 if(state==3){vx=-ux*speed*0.65f-uy*orbit*25.0f;vy=-uy*speed*0.65f+ux*orbit*25.0f;}
 // Ranged survivors learn whether holding distance or flanking survives the player's fire.
 if(type==2&&dist<165.0f+Old[b+42]*145.0f&&state<4){vx=-ux*speed*0.65f-uy*orbit*40.0f;vy=-uy*speed*0.65f+ux*orbit*40.0f;}
 if(state<4&&Old[b+11]>0.1f&&facing>0.65f) {vx+=-uy*orbit*Old[b+43]*80.0f;vy+=ux*orbit*Old[b+43]*80.0f;}
 if(state<4&&E[b+10]<=0.0f&&((type==2&&dist<410.0f)||(type!=2&&dist<(type==1?70.0f+Old[b+42]*50.0f:36.0f+Old[b+42]*28.0f)))) {
  state=4;E[b+34]=type==3?0.70f:0.48f;E[b+27]=(tx-ex)/td;E[b+28]=(ty-ey)/td;
 }
 if(state==4) {
  vx=0.0f;vy=0.0f;E[b+34]-=dt;
  if(E[b+34]<=0.0f) {
   if(type==2) {E[b+29]=ex;E[b+30]=ey-10.0f;E[b+31]=E[b+27]*210.0f;E[b+32]=E[b+28]*210.0f;E[b+33]=2.5f;state=0;E[b+10]=1.9f+(1.0f-Old[b+45])*1.1f;}
   else {state=5;E[b+34]=0.22f;E[b+10]=1.05f+(1.0f-Old[b+45])*0.65f;}
  }
 }
 if(state==5) {
  E[b+34]-=dt;vx=E[b+27]*(type==3?170.0f:275.0f);vy=E[b+28]*(type==3?170.0f:275.0f);
  if(dist<radius+15.0f&&Old[b+10]>0.8f) {E[b+20]=type==3?20.0f:11.0f;E[b+10]=0.75f;}
  if(E[b+34]<=0.0f)state=0;
 }
 E[b+8]=(float)state;
 if(E[b+33]>0.0f) {
  float sx=E[b+29];float sy=E[b+30];E[b+29]+=E[b+31]*dt;E[b+30]+=E[b+32]*dt;E[b+33]-=dt;
  if(segment(px,py,sx,sy,E[b+29],E[b+30])<13.0f){E[b+20]+=12.0f;E[b+33]=0.0f;}
 }
 // Bounded neighbour sampling: separate bodies without an O(N^2) all-pairs solver.
 for(int k=1;k<=12;k++) {
  int n=((i+k*23)%ENEMIES)*ES;
  if(Old[n+4]>0.0f) {float sx=ex-Old[n];float sy=ey-Old[n+1];float sd=len2(sx,sy);float space=22.0f+Old[b+44]*17.0f;if(sd>0.1f&&sd<space){vx+=sx/sd*(space-sd)*2.4f;vy+=sy/sd*(space-sd)*2.4f;}}
 }
 vx+=E[b+25];vy+=E[b+26];E[b+25]*=0.80f;E[b+26]*=0.80f;
 float xx=ex+vx*dt;float yy=ey+vy*dt;
 if(obstacle(xx,ey)>radius*0.7f)ex=xx;else ey+=orbit*speed*dt;
 if(obstacle(ex,yy)>radius*0.7f)ey=yy;else ex+=orbit*speed*dt;
 E[b]=ex;E[b+1]=ey;E[b+2]=vx;E[b+3]=vy;
 // Despawn stragglers; do not count them as player kills or useful selection samples.
 if(dist>1600.0f){E[b+4]=0.0f;E[b+33]=0.0f;}
}
__global__ void evolvePopulation(const float* S,float* G,float* Brain) {
 if(threadIdx.x!=0||blockIdx.x!=0||S[8]!=1.0f||S[45]<0.5f||S[51]<0.5f)return;
 if(((int)S[7])%1200!=0)return;
 for(int species=0;species<5;species++) {
  int best=species*8;int worst=best+1;float hi=-1.0f;float lo=1000.0f;
  for(int j=0;j<8;j++){int g=species*8+j;float score=G[g*16+6];if(G[g*16+7]>=2.0f&&score>hi){hi=score;best=g;}if(score<lo){lo=score;worst=g;}}
  if(hi>=0.0f&&best!=worst) {
   for(int p=0;p<6;p++)G[worst*16+p]=fmaxf(0.08f,fminf(0.92f,G[best*16+p]+(hashf(S[7]+(float)(p*37+species*41))-0.5f)*0.25f));
   for(int p=9;p<16;p++)G[worst*16+p]=0.0f;G[worst*16+9]=(float)best;
   G[worst*16+6]=hi*0.45f;G[worst*16+7]=0.0f;G[worst*16+8]=G[best*16+8]+1.0f;
   Brain[12]+=1.0f;Brain[13]=fmaxf(Brain[13],G[worst*16+8]);
  }
 }
}

// ===== LEARNING =====
// Online supervised learning: 16 -> 32 tanh -> 2 linear residuals, 610 parameters.
// A zero-initialized output layer starts exactly at constant-velocity prediction.
// Training learns a correction, rather than relearning elementary motion from nothing.
// Future labels mature after 5 * 0.1 s. No future player input is exposed to enemies.
// Prequential errors are scored BEFORE these observations become training targets.
__device__ float activation(float x) { return 2.0f/(1.0f+expf(-2.0f*fmaxf(-8.0f,fminf(8.0f,x))))-1.0f; }
__device__ bool trainNow(const float* S,const float* Brain) {return S[8]==1.0f&&S[51]>0.5f&&S[45]>0.5f&&((int)S[7])%12==0&&Brain[10]>=40.0f;}
__global__ void recordExperience(const float* S,const float* E,const float* I,float* R,float* Brain) {
 if(threadIdx.x!=0||blockIdx.x!=0)return;
 if(S[49]>0.5f){Brain[10]=0.0f;Brain[7]=0.0f;return;}
 if(S[8]!=1.0f||S[51]<0.5f||((int)S[7])%6!=0)return;
 int count=(int)Brain[10];int idx=count%REPLAY;int b=idx*RS;
 if(count>=5){
  int older=((count-5)%REPLAY)*RS;float tx=fmaxf(-1.5f,fminf(1.5f,(S[0]-R[older+16])/140.0f));float ty=fmaxf(-1.5f,fminf(1.5f,(S[1]-R[older+17])/140.0f));
  float error=(tx-R[older+20])*(tx-R[older+20])+(ty-R[older+21])*(ty-R[older+21]);
  float baseline=(tx-R[older+22])*(tx-R[older+22])+(ty-R[older+23])*(ty-R[older+23]);
  R[older+18]=tx;R[older+19]=ty;R[older+24]=1.0f;R[older+26]=error;
  float alpha=Brain[1]<1.0f?1.0f:0.025f;
  Brain[2]=mixf(Brain[2],error,alpha);Brain[3]=mixf(Brain[3],baseline,alpha);Brain[1]+=1.0f;
  // Revert to ordinary velocity leading unless the learned predictor actually beats it.
  Brain[4]=Brain[1]>64.0f?fminf(0.75f,fmaxf(0.0f,1.0f-(Brain[2]+0.002f)/(Brain[3]+0.002f))):0.0f;
  Brain[7]=fminf((float)(REPLAY-5),(float)(count-4));
 }
 int p1=((count+REPLAY-1)%REPLAY)*RS;int p5=((count+REPLAY-5)%REPLAY)*RS;
 R[b]=S[2]/180.0f;R[b+1]=S[3]/180.0f;
 R[b+2]=count>0?R[p1]:0.0f;R[b+3]=count>0?R[p1+1]:0.0f;
 R[b+4]=count>=5?R[p5]:0.0f;R[b+5]=count>=5?R[p5+1]:0.0f;
 R[b+6]=S[23];R[b+7]=S[24];R[b+8]=I[4]>0.5f||S[31]>0.5f?1.0f:0.0f;R[b+9]=I[5];
 R[b+10]=S[14]>0.0f?1.0f:0.0f;R[b+11]=S[4]/S[5];
 float near=1000000.0f;float dx=0.0f;float dy=0.0f;float density=0.0f;
 for(int j=0;j<ENEMIES;j++)if(E[j*ES+4]>0.0f){float x=E[j*ES]-S[0];float y=E[j*ES+1]-S[1];float d=x*x+y*y;if(d<near){near=d;dx=x;dy=y;}if(d<48400.0f)density+=1.0f;}
 R[b+12]=fmaxf(-1.0f,fminf(1.0f,dx/300.0f));R[b+13]=fmaxf(-1.0f,fminf(1.0f,dy/300.0f));R[b+14]=fminf(1.0f,density/35.0f);
 R[b+15]=R[b]*R[b+3]-R[b+1]*R[b+2];
 R[b+16]=S[0];R[b+17]=S[1];R[b+18]=0.0f;R[b+19]=0.0f;R[b+20]=Brain[8];R[b+21]=Brain[9];
 R[b+22]=fmaxf(-1.5f,fminf(1.5f,S[2]*0.5f/140.0f));R[b+23]=fmaxf(-1.5f,fminf(1.5f,S[3]*0.5f/140.0f));R[b+24]=0.0f;R[b+25]=S[6];
 Brain[10]+=1.0f;Brain[11]+=1.0f;
}
__global__ void prepareBatch(const float* S,const float* Brain,const float* R,float* Work) {
 int i=(int)(blockIdx.x*blockDim.x+threadIdx.x);if(i>=BATCH||!trainNow(S,Brain))return;
 int count=(int)Brain[10];int available=count-5;if(available>REPLAY-5)available=REPLAY-5;
 int span=i%2==0?(available<64?available:64):available;
 int age=(int)(hashf(S[7]+(float)(i*173)+Brain[0]*0.41f)*(float)span);
 int seq=count-6-age;int rb=((seq+REPLAY*4)%REPLAY)*RS;int wb=i*WS;
 for(int j=0;j<16;j++)Work[wb+j]=R[rb+j];Work[wb+16]=R[rb+18];Work[wb+17]=R[rb+19];
}
__global__ void forwardBatch(const float* S,const float* Brain,const float* W,float* Work) {
 int i=(int)(blockIdx.x*blockDim.x+threadIdx.x);if(i>=BATCH||!trainNow(S,Brain))return;int b=i*WS;
 for(int h=0;h<HIDDEN;h++){float z=W[512+h];for(int j=0;j<INPUTS;j++)z+=W[h*INPUTS+j]*Work[b+j];Work[b+20+h]=activation(z);}
 for(int o=0;o<2;o++){float z=W[608+o];for(int h=0;h<HIDDEN;h++)z+=W[544+o*HIDDEN+h]*Work[b+20+h];Work[b+18+o]=Work[b+o]*(90.0f/140.0f)+z;}
}
__global__ void backwardBatch(const float* S,const float* Brain,const float* W,float* Work) {
 int i=(int)(blockIdx.x*blockDim.x+threadIdx.x);if(i>=BATCH||!trainNow(S,Brain))return;int b=i*WS;float loss=0.0f;
 for(int o=0;o<2;o++){float y=Work[b+18+o];float d=y-Work[b+16+o];Work[b+84+o]=d;loss+=d*d*0.5f;}
 Work[b+86]=loss;
 for(int h=0;h<HIDDEN;h++){float hval=Work[b+20+h];float d=Work[b+84]*W[544+h]+Work[b+85]*W[576+h];Work[b+52+h]=d*(1.0f-hval*hval);}
}
__global__ void computeGradient(const float* S,float* Brain,const float* Work,float* Grad) {
 int i=(int)(blockIdx.x*blockDim.x+threadIdx.x);if(i>=PARAMS||!trainNow(S,Brain))return;float grad=0.0f;
 for(int n=0;n<BATCH;n++){
  int b=n*WS;
  if(i<512)grad+=Work[b+52+i/16]*Work[b+i%16];
  else if(i<544)grad+=Work[b+52+i-512];
  else if(i<608)grad+=Work[b+84+(i-544)/32]*Work[b+20+(i-544)%32];
  else grad+=Work[b+84+i-608];
 }
 Grad[i]=fmaxf(-0.8f,fminf(0.8f,grad/(float)BATCH));
 if(i==0){float loss=0.0f;for(int n=0;n<BATCH;n++)loss+=Work[n*WS+86];Brain[5]=loss/(float)BATCH;Brain[0]+=1.0f;}
}
__global__ void updateWeights(const float* S,const float* Brain,const float* Grad,float* W,float* M,float* V) {
 int i=(int)(blockIdx.x*blockDim.x+threadIdx.x);if(i>=PARAMS||!trainNow(S,Brain))return;
 float grad=Grad[i];float m=0.9f*M[i]+0.1f*grad;float v=0.999f*V[i]+0.001f*grad*grad;M[i]=m;V[i]=v;
 float mh=m/(1.0f-powf(0.9f,Brain[0]));float vh=v/(1.0f-powf(0.999f,Brain[0]));
 W[i]-=0.002f*(mh/(sqrtf(vh)+0.00001f)+0.0001f*W[i]);
}
__global__ void inferPlayer(const float* S,float* R,const float* W,float* Brain) {
 if(threadIdx.x!=0||blockIdx.x!=0||S[8]!=1.0f||Brain[10]<1.0f)return;
 int idx=(((int)Brain[10]-1)%REPLAY)*RS;float H[32];
 for(int h=0;h<HIDDEN;h++){float z=W[512+h];for(int j=0;j<INPUTS;j++)z+=W[h*INPUTS+j]*R[idx+j];H[h]=activation(z);}
 for(int o=0;o<2;o++){float z=W[608+o];for(int h=0;h<HIDDEN;h++)z+=W[544+o*HIDDEN+h]*H[h];Brain[8+o]=fmaxf(-1.5f,fminf(1.5f,R[idx+o]*(90.0f/140.0f)+z));if(S[51]>0.5f&&((int)S[7])%6==0)R[idx+20+o]=Brain[8+o];}
}

// ===== RENDER =====
// Every visible world pixel is computed here. No raster scene, imported sprites or Three.js.
#define TILE 32
#define TILE_CAP 64
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
 // Telegraphs are on the ground, before the creature silhouette.
 if(E[b+8]==4.0f) {
  float r=type==3?36.0f:27.0f;float ring=fabsf(len2(x,y*1.2f)-r)-1.2f;
  c=paint(c,color(0.73f,0.25f,0.12f),ink(ring,aa)*0.8f);
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
 int b=id*TILE_CAP;int count=0;float cx=(float)(id%tw*32+16);float cy=(float)(id/tw*32+16);float zoom=(float)height/700.0f;
 for(int i=0;i<ENEMIES;i++)if(E[i*ES+4]!=0.0f){
  float sx=(E[i*ES]-S[25])*zoom+(float)width*0.5f;float sy=(E[i*ES+1]-S[26])*zoom+(float)height*0.5f;
  if(fabsf(sx-cx)<60.0f*zoom+16.0f&&fabsf(sy-18.0f*zoom-cy)<70.0f*zoom+16.0f&&count<TILE_CAP-1){Tiles[b+1+count]=i;count++;}
 }
 for(int i=0;i<BULLETS;i++)if(P[i*BS+6]>0.0f){
  float sx=(P[i*BS]-S[25])*zoom+(float)width*0.5f;float sy=(P[i*BS+1]-S[26])*zoom+(float)height*0.5f;
  if(fabsf(sx-cx)<25.0f*zoom+16.0f&&fabsf(sy-cy)<25.0f*zoom+16.0f&&count<TILE_CAP-1){Tiles[b+1+count]=1000+i;count++;}
 }
 for(int i=0;i<ENEMIES;i++)if(E[i*ES+4]>0.0f&&E[i*ES+33]>0.0f){
  float sx=(E[i*ES+29]-S[25])*zoom+(float)width*0.5f;float sy=(E[i*ES+30]-S[26])*zoom+(float)height*0.5f;
  if(fabsf(sx-cx)<22.0f*zoom+16.0f&&fabsf(sy-cy)<22.0f*zoom+16.0f&&count<TILE_CAP-1){Tiles[b+1+count]=2000+i;count++;}
 }
 Tiles[b]=count;
}
__global__ void renderWorld(const float* S,const float* E,const float* P,const int* Tiles,unsigned int* Pixels,int width,int height) {
 int ix=(int)(blockIdx.x*blockDim.x+threadIdx.x);int iy=(int)(blockIdx.y*blockDim.y+threadIdx.y);if(ix>=width||iy>=height)return;
 float zoom=(float)height/700.0f;float aa=1.1f/zoom;float time=S[46];float gameTime=S[6];
 float wx=((float)ix-(float)width*0.5f)/zoom+S[25];float wy=((float)iy-(float)height*0.5f)/zoom+S[26];
 float pd=len2(wx-S[0],wy-S[1]);float radial=len2(wx,wy);
 float ground=noise2(wx*0.018f,wy*0.018f);float detail=noise2(wx*0.23f,wy*0.23f);
 float4 c=color(0.071f+ground*0.035f,0.091f+ground*0.041f,0.092f+ground*0.038f);
 float stone=smooth01(1.0f,0.0f,noise2(wx*0.008f,wy*0.008f)*1.7f-0.1f);
 if(radial<250.0f)stone=1.0f;
 float row=floorf(wy/33.0f);float tx=frac((wx+((row-floorf(row/2.0f)*2.0f))*28.0f)/57.0f);float ty=frac(wy/33.0f);
 float joint=fminf(fminf(tx,1.0f-tx)*57.0f,fminf(ty,1.0f-ty)*33.0f);
 float stoneNoise=h2(floorf((wx+(row-floorf(row/2.0f)*2.0f)*28.0f)/57.0f),row);
 float4 paving=color(0.13f+stoneNoise*0.028f,0.151f+stoneNoise*0.033f,0.149f+stoneNoise*0.035f);
 paving=paving*(0.65f+detail*0.43f);paving=blend(color(0.042f,0.052f,0.052f),paving,smooth01(0.0f,1.4f,joint));c=blend(c,paving,stone*0.78f);
 // Cracked flagstones and short wet grass occupy different materials.
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
  if(d<aa){front=make_float4(prop.x,prop.y,prop.z,ink(d,aa));depth=oy;}
 }
 int tile=((iy/32)*((width+31)/32)+ix/32)*TILE_CAP;int count=Tiles[tile];
 for(int j=0;j<count;j++)if(Tiles[tile+1+j]<1000){
  int b=Tiles[tile+1+j]*ES;float x=wx-E[b];float y=wy-E[b+1];
  float sh=expf(-len2(x/1.5f,y/0.55f)/12.0f)*0.35f;c=c*(1.0f-sh);
  float4 sprite=enemyArt(x,y,E,b,gameTime,aa);
  if(sprite.w>0.01f&&E[b+1]>=depth){front=sprite;depth=E[b+1];}
 }
 float pshadow=expf(-len2((wx-S[0])/1.45f,(wy-S[1])/0.55f)/12.0f)*0.45f;c=c*(1.0f-pshadow);
 float4 player=playerArt(wx-S[0],wy-S[1],S,aa);
 if(player.w>0.01f&&S[1]>=depth){front=player;depth=S[1];}
 c=blend(c,color(front.x,front.y,front.z),front.w);
 // Tiny brazier geometry, flame and sparks; emissive shapes remain readable in shadow.
 for(int k=0;k<4;k++) {
  float fx=k%2==0?-214.0f:214.0f;float fy=k<2?-144.0f:144.0f;float x=wx-fx;float y=wy-fy;
  if(fabsf(x)<23.0f&&fabsf(y)<55.0f&&fy>=depth){
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
 float rainX=wx*0.10f+wy*0.025f;float rainY=wy*0.07f+time*10.0f;float cell=h2(floorf(rainX),floorf(rainY));
 float rain=ink(fabsf(frac(rainX)-0.5f)-0.035f,0.035f)*(1.0f-frac(rainY))*0.10f;
 if(cell>0.83f)c=c+color(rain*0.8f,rain,rain);
 float nx=((float)ix/(float)width-0.5f)*2.0f;float ny=((float)iy/(float)height-0.5f)*2.0f;float vignette=1.0f-0.25f*powf(sat((nx*nx+ny*ny)*0.48f),1.3f);
 c=c*vignette;float grain=(h2((float)ix+floorf(time*12.0f),(float)iy)-0.5f)*0.013f;c.x+=grain;c.y+=grain;c.z+=grain;
 if(S[4]<35.0f&&S[8]==1.0f){float danger=(1.0f-S[4]/35.0f)*sat((nx*nx+ny*ny)*0.45f);c=blend(c,color(0.30f,0.038f,0.027f),danger*0.45f);}
 Pixels[iy*width+ix]=rgba(c);
}

// ===== UI =====
// GPU interface, including lettering and the title. No DOM gameplay HUD.
__constant__ unsigned int GlyphLow[64] = {0u,0u,0u,0u,0u,2894205785u,0u,0u,0u,0u,0u,139432064u,0u,1015808u,134217728u,276957249u,2744831534u,2286031236u,3766683182u,2182546494u,2247698626u,2183086623u,2736734734u,276957247u,2736211502u,2182596142u,138416256u,0u,0u,0u,0u,0u,0u,1663026734u,2736735806u,3775414799u,2736309822u,3775873567u,554648095u,3810247183u,1663026737u,3359772831u,622921799u,1699500625u,3775414800u,1662703473u,1662637873u,2736309806u,554649150u,1700316718u,1699694142u,2182562319u,138547359u,2736309809u,353945137u,2874852913u,1654794801u,138553905u,3766618175u,2424578318u,0u,2216757326u,0u,0u};
__constant__ unsigned int GlyphHigh[64] = {0u,0u,0u,0u,0u,1u,0u,0u,0u,0u,0u,0u,0u,0u,1u,4u,3u,3u,7u,7u,0u,7u,3u,2u,3u,3u,0u,0u,0u,0u,0u,0u,0u,4u,7u,3u,7u,7u,4u,3u,4u,7u,3u,4u,7u,4u,4u,3u,4u,3u,4u,7u,1u,3u,1u,2u,4u,1u,7u,3u,0u,3u,0u,0u};
__constant__ unsigned int TextOffset[65] = {0u,20u,44u,72u,89u,105u,127u,149u,186u,223u,248u,256u,261u,263u,267u,273u,277u,286u,294u,307u,314u,336u,348u,383u,393u,403u,415u,428u,440u,448u,466u,483u,505u,527u,554u,573u,578u,593u,614u,648u,656u,667u,699u,718u,729u,743u,763u,779u,796u,813u,831u,864u,900u,937u,974u,984u,986u,989u,1015u,1019u,1029u,1034u,1037u,1038u,1043u};
__constant__ unsigned int TextLength[65] = {20u,24u,28u,17u,16u,22u,22u,37u,37u,25u,8u,5u,2u,4u,6u,4u,9u,8u,13u,7u,22u,12u,35u,10u,10u,12u,13u,12u,8u,18u,17u,22u,22u,27u,19u,5u,15u,21u,34u,8u,11u,32u,19u,11u,14u,20u,16u,17u,17u,18u,33u,36u,37u,37u,10u,2u,3u,26u,4u,10u,5u,3u,1u,5u,39u};
__constant__ unsigned int TextBlock0[256] = {541411412u,1280069448u,1377851215u,1296387397u,1397900610u,1229725761u,1196312918u,1381323552u,1096173910u,1330126924u,1380930130u,1497712724u,1095060512u,1411403346u,1461732680u,1495292225u,1293964623u,776296015u,1162559821u,1162368032u,1329995853u,1413826386u,1414415662u,1411404357u,1210074440u,1330400335u,1414415703u,790647365u,1229734688u,1411402563u,1161961551u,1414416711u,1293962821u,1414876745u,1428181829u,1279874126u,1463895072u,1396791118u,1293951044u,541414991u,1293951008u,1163089231u,1229004832u,538976333u,1112362016u,1229332512u,1297237330u,1394614338u,1213487427u,538976325u,1095783200u,538985795u,1213415748u,538976288u,1461723205u,1279545921u,1279345487u,1296387360u,542724687u,1330520111u,1413828128u,1263685463u,1096042838u,1498696012u,1229016147u,1146506318u,1397248833u,1213487427u,1380013893u,1396854596u,1230393925u,1145128782u,1230262337u,1162692430u,1498566477u,1330791968u,1280197978u,1095061065u,1213482311u,1330126917u,1464814668u,542329120u,1129595223u,1196312904u,1145981250u,1377845536u,1128877125u,1330595907u,1461732691u,542392648u,542461785u,1381122371u,1313415257u,1411403604u,1142965576u,1196118593u,1163280722u,1330792736u,1230328142u,1313164099u,1111969353u,1146048332u,1397052960u,1397507411u,1313426512u,542262612u,1414482003u,1329875287u,1279402071u,1397048385u,1145979223u,1380274757u,624046635u,1095063328u,542003024u,1095582020u,824919367u,1176511799u,1313428041u,1347625031u,725894469u,1444951346u,1279349833u,542725193u,1162354735u,891309121u,540093237u,1380272464u,1196312899u,1330794528u,1413694794u,1329941577u,1414087250u,541544009u,1145130050u,539959365u,1280659283u,1095062048u,942360643u,1347624997u,541345093u,1162354735u,840977473u,1163022389u,1213485907u,1229856837u,542394439u,1145851720u,1129530707u,1159737120u,1380275278u,542069792u,1431586130u,1331252818u,1293963861u,1296389711u,542395973u,1094927682u,1411401037u,1380533576u,1296387360u,777605711u,542461785u,1280066886u,1314341188u,1163018784u,1414744897u,1380533576u,1296387360u,542724687u,1448236371u,1397053001u,1162368032u,1195986464u,1160664136u,1380275278u,542069792u,1263288663u,1095188768u,1229344329u,541346885u,1163153230u,1095914579u,1313427017u,1414733895u,1297305669u,1381323841u,1327514693u,1380275010u,1230258518u,1347636815u,1229210962u,1330205763u,1380261966u,1448234834u,1129270341u,542725193u,1163084098u,1162758476u,1380009292u,541345102u,1279675977u,1129203029u,1279611717u,1163150149u,1431117892u,1230258516u,1314082383u,1430659151u,1163023700u,1347307808u,790647893u,542068256u,1330464082u,1293960532u,1279607887u,1176510540u,1514489170u,1162616901u,1229869633u,538986318u,541597728u,1162429984u,1310737484u,1397052495u,1176510534u,1397509205u,1162170947u,538976334u,1394614349u,1145984335u,1361059872u,1431380000u,1414089793u,540427865u,1347962144u,542397007u,1330464077u,538990930u,540493344u,1347242272u,542397007u,1330464077u,1145133394u,1096044609u,1313818964u,1179602511u,538989638u,1330926913u,1380533792u,538976325u,1129530656u,1095770144u,1464161109u,1195726401u,1380273733u};
__constant__ unsigned int TextBlock1[15] = {1330205761u,1095783246u,1297237315u,1330857282u,1280527445u,1314013509u,541544009u,1277186889u,1279345487u,1162092590u,541611073u,1310741321u,1092637775u,1313153102u,11844u};
__constant__ unsigned int TitleBlock0[256] = {0u,0u,8384512u,0u,32764u,0u,0u,0u,0u,0u,0u,0u,0u,8191u,524272u,67108352u,2147483648u,2148532223u,4294967295u,4294951935u,2147418113u,4294967232u,4278190087u,4026531871u,4294838271u,8388607u,16383u,524272u,536870848u,4026531840u,2164260863u,4294967295u,4294951935u,2147418113u,4294967232u,4278190143u,4026531903u,4294838271u,8388607u,16383u,524272u,1069555680u,4160749568u,2214584327u,4294967295u,4294951935u,2147418113u,4294967232u,4278190335u,4026531903u,4294838271u,8388607u,32704u,7168u,4261413880u,4261412864u,2214526976u,16646147u,133170048u,29360128u,520192u,3221225983u,127u,1065353244u,7340032u,65472u,7168u,4160749820u,1056964609u,2214330368u,16646147u,133170048u,29360128u,520192u,3221226492u,255u,1065353244u,7340032u,131008u,7168u,4026531966u,528482307u,2214068224u,16646147u,133170048u,29360128u,520192u,3221227504u,511u,1065353244u,7340032u,262080u,7168u,3758096447u,264241159u,2213543936u,16646147u,133170048u,29360128u,520192u,3221229552u,1023u,1065353244u,7340032u,262080u,2147490816u,3221225503u,132120591u,2212495360u,16646147u,133170048u,29360128u,520192u,3221229536u,1023u,1065353244u,7340032u,523712u,3221232640u,3221225487u,133169183u,2212495360u,16646147u,133170048u,29360128u,520192u,3221229536u,2045u,1065353244u,7340032u,1046976u,3221232640u,2147483663u,66060319u,2210398208u,16646147u,133170048u,29360128u,520192u,3221233600u,4089u,1065353244u,7340032u,2093504u,3758103552u,7u,33030207u,2210398208u,16646147u,133170048u,29360128u,520192u,3221233600u,8177u,1065353244u,0u,2089408u,3758103552u,7u,33030207u,58720256u,16646144u,133169152u,29360128u,520192u,3221233600u,8161u,1065353244u,0u,4186560u,4026539008u,7u,33292415u,58720256u,16646144u,133169152u,29360128u,520192u,3221233600u,16353u,1065353244u,0u,8372672u,4026539008u,3u,16515198u,0u,16646144u,133169152u,29360128u,520192u,3221233600u,32705u,1065353244u,0u,16744896u,4160756736u,3u,16646398u,0u,16646144u,133169152u,29360128u,520192u,3221233600u,65409u,1065353244u,114688u,16712128u,4160756736u,3u,16646398u,0u,16646144u,133169152u,29360128u,520192u,3221233600u,65281u,1065353244u,114688u,33489344u,4160756736u,3u,16646398u,0u,16646144u,133169152u,29360128u,520192u,3221233600u,130817u,1065353244u,114688u,66978240u,4160756736u,1u,8257788u,0u,16646144u,133169152u,29360128u,520192u,3221229536u,261633u,1065353244u,114688u,133956032u,4227865600u,1u,8323580u,0u,16646144u,133169152u,29360128u,520192u};
__constant__ unsigned int TitleBlock1[256] = {3221229536u,523265u,1065353244u,114688u,133693888u,4227865600u,1u,8323580u,0u,16646144u,133169152u,29360128u,520192u,3221227504u,522241u,1065353244u,114688u,267911616u,4227865600u,1u,8323580u,0u,16646144u,133169152u,29360128u,520192u,3221227504u,1046529u,4286578716u,131071u,535822784u,4227865600u,1u,8323580u,0u,16646144u,133169152u,29360128u,520192u,3221226492u,2093057u,4286578716u,131071u,1071645120u,4227865600u,1u,8323580u,0u,16646144u,133169152u,29360128u,520192u,3221225983u,4186113u,4286578716u,131071u,1069547968u,4227865600u,1u,8323580u,0u,16646144u,133169152u,29360128u,4294963200u,3221225599u,4177921u,1065353244u,114688u,2143289792u,4227865600u,1u,8323580u,0u,16646144u,133169152u,29360128u,4294963200u,3221225479u,8372225u,1065353244u,114688u,4286579136u,4227865600u,1u,8323580u,0u,16646144u,133169152u,29360128u,4294963200u,3221225487u,16744449u,1065353244u,114688u,4278190528u,4227865601u,1u,8323580u,0u,16646144u,133169152u,29360128u,3758616576u,3221225535u,33488897u,1065353244u,114688u,4261413312u,4227865601u,1u,8323580u,0u,16646144u,133169152u,29360128u,2148003840u,3221225599u,33423361u,1065353244u,114688u,4261413312u,4227865603u,1u,8323580u,0u,16646144u,133169152u,29360128u,520192u,3221225727u,66977793u,1065353244u,114688u,4227858880u,4227865607u,1u,8323580u,0u,16646144u,133169152u,29360128u,520192u,3221225727u,133955585u,1065353244u,0u,4160750016u,4160756751u,1u,8257788u,0u,16646144u,133169152u,29360128u,520192u,3221225982u,267911169u,1065353244u,0u,4026532288u,4160756751u,3u,16646398u,0u,16646144u,133169152u,29360128u,520192u,3221225982u,267386881u,1065353244u,0u,4026532288u,4160756767u,3u,16646398u,0u,16646144u,133169152u,29360128u,520192u,3221226492u,535822337u,1065353244u,0u,3758096832u,4160756799u,3u,16646398u,0u,16646144u,133169152u,29360128u,520192u,3221226488u,1071644673u,1065353244u,0u,3221225920u,4026539135u,3u,16515198u,0u,16646144u,133169152u,29360128u,520192u,3221227512u,2143289345u,1065353244u,0u,2147484096u,4026539135u,7u,33292415u,132120576u,16646144u,267386880u,31457280u,520192u,3221227512u,2139095041u,1065353244u,0u,2147484096u,3758103807u,7u,33030207u,66060288u,16646144u,266338304u,14680064u,520192u,3221229552u,4286578689u,1065353244u,0u,448u,3758104063u,7u,33030207u,66060288u,16646144u,266338304u,14680064u,520192u,3221229552u,4278190081u,1065353245u,0u,448u,3221233662u,2147483663u,66060319u,66060288u};
__constant__ unsigned int TitleBlock2[138] = {16646144u,266338304u,14680064u,520192u,3221233632u,4261412865u,1065353247u,14680064u,448u,3221233660u,3221225503u,66060303u,33030144u,16646144u,534773760u,15728640u,520192u,3221233632u,4227858433u,1065353247u,14680064u,448u,2147491836u,3221225503u,132120591u,16515072u,16646144u,532676608u,7340032u,520192u,3221241792u,4227858433u,1065353247u,14680064u,448u,8184u,3758096447u,264241159u,16515072u,16646144u,1069547520u,7864320u,520192u,3221241792u,4160749569u,1065353247u,14680064u,448u,8176u,4026531966u,528482307u,8257536u,16646144u,2139095040u,3932160u,520192u,3221258112u,4026531841u,1065353247u,14680064u,448u,8160u,4160749820u,1056964609u,4128768u,16646144u,4286578688u,4128769u,520192u,3221258112u,3758096385u,1065353247u,14680064u,448u,8128u,4261413880u,4261412864u,2080768u,16646144u,4278190080u,2088975u,520192u,3221257984u,3221225473u,1065353247u,14680064u,32767u,8128u,1069555680u,4160749568u,1046535u,1073739776u,4261412864u,1048575u,33554368u,4282384128u,3221225599u,4294836255u,16777215u,32767u,8064u,536870848u,4026531840u,262143u,1073739776u,4160749568u,262143u,33554368u,4282383872u,2147483775u,4294836255u,16777215u,32767u,7936u,67108352u,2147483648u,65535u,1073739776u,3758096384u,65535u,33554368u,4282383872u,127u,4294836255u,16777215u,0u,7680u,8384512u,0u,4092u,0u,0u,4095u,0u,0u,0u,30u,0u};
__device__ unsigned int textWord(int i) {
 if(i<256)return TextBlock0[i-0];
 if(i<271)return TextBlock1[i-256];
 return 0u; }
__device__ unsigned int titleWord(int i) {
 if(i<256)return TitleBlock0[i-0];
 if(i<512)return TitleBlock1[i-256];
 if(i<650)return TitleBlock2[i-512];
 return 0u; }
#define TITLE_W 408
#define TITLE_H 50
#define TITLE_STRIDE 13
__device__ float glyph(float x,float y,int ch,float scale) {
 float gx=x/scale;float gy=y/scale;int xx=(int)floorf(gx);int yy=(int)floorf(gy);
 if(xx<0||xx>=5||yy<0||yy>=7||ch<32||ch>=96)return 0.0f;
 int bit=yy*5+4-xx;unsigned int bits=bit<32?GlyphLow[ch-32]:GlyphHigh[ch-32];int shift=bit<32?bit:bit-32;
 return (float)((bits>>shift)&1u);
}
__device__ float4 label(float4 c,float x,float y,float ox,float oy,int phrase,float scale,float4 tint) {
 float xx=x-ox;float yy=y-oy;int len=(int)TextLength[phrase];if(xx<0.0f||yy<0.0f||yy>=7.0f*scale||xx>=(float)len*6.0f*scale)return c;
 int pos=(int)floorf(xx/(6.0f*scale));int idx=(int)TextOffset[phrase]+pos;unsigned int word=textWord(idx/4);int ch=(int)((word>>((idx%4)*8))&255u);
 return blend(c,tint,glyph(xx-(float)pos*6.0f*scale,yy,ch,scale));
}
__device__ float4 centered(float4 c,float x,float y,float cx,float oy,int phrase,float scale,float4 tint) {return label(c,x,y,cx-(float)TextLength[phrase]*3.0f*scale,oy,phrase,scale,tint);}
__device__ float4 number(float4 c,float x,float y,float ox,float oy,int value,int digits,float scale,float4 tint) {
 float xx=x-ox;float yy=y-oy;if(xx<0.0f||yy<0.0f||yy>=7.0f*scale||xx>=(float)digits*6.0f*scale)return c;
 int pos=(int)floorf(xx/(6.0f*scale));int power=1;for(int j=0;j<6;j++)if(j<digits-pos-1)power*=10;
 int ch=48+(value/power)%10;return blend(c,tint,glyph(xx-(float)pos*6.0f*scale,yy,ch,scale));
}
__device__ float titleBit(int x,int y) {if(x<0||y<0||x>=TITLE_W||y>=TITLE_H)return 0.0f;return (float)((titleWord(y*TITLE_STRIDE+x/32)>>(x%32))&1u);}
__device__ float titleMask(float x,float y) {
 int xx=(int)floorf(x);int yy=(int)floorf(y);float fx=frac(x);float fy=frac(y);
 return mixf(mixf(titleBit(xx,yy),titleBit(xx+1,yy),fx),mixf(titleBit(xx,yy+1),titleBit(xx+1,yy+1),fx),fy);
}
__device__ float4 panel(float4 c,float x,float y,float cx,float cy,float w,float h,float light) {
 float d=boxd(x-cx,y-cy,w*0.5f,h*0.5f);c=blend(c,color(0.023f,0.028f,0.029f),ink(d,1.0f)*0.95f);
 return blend(c,color(0.40f*light,0.34f*light,0.24f*light),ink(fabsf(d)-0.65f,1.0f));
}
__device__ float4 relic(float4 c,float x,float y,int kind,float4 gold) {
 float d=1000.0f;
 if(kind==0)d=fminf(segment(x,y,-12.0f,15.0f,12.0f,-15.0f)-2.5f,segment(x,y,-10.0f,-7.0f,10.0f,7.0f)-1.8f);
 if(kind==1)d=fminf(fabsf(len2(x,y)-16.0f)-1.0f,segment(x,y,0.0f,0.0f,8.0f,-11.0f)-1.6f);
 if(kind==2)d=fmaxf(fabsf(x)-15.0f,fabsf(y+2.0f)-10.0f); // Vessel over a blood-drop engraving.
 if(kind==2)d=fminf(fabsf(len2(x,y+9.0f)-12.0f)-1.3f,fabsf(segment(x,y,-11.0f,-9.0f,0.0f,17.0f)-1.0f));
 if(kind==3){for(int k=-1;k<=1;k++)d=fminf(d,segment(x,y,(float)k*5.0f,15.0f,(float)k*14.0f,-15.0f)-1.6f);}
 if(kind==4){d=fabsf(len2(x,y)-17.0f)-0.8f;d=fminf(d,segment(x,y,-16.0f,15.0f,16.0f,-15.0f)-1.8f);}
 if(kind==5)d=fminf(segment(x,y,-11.0f,15.0f,0.0f,-17.0f)-2.0f,segment(x,y,0.0f,-17.0f,12.0f,8.0f)-2.0f);
 return blend(c,gold,ink(d,1.2f));
}
__global__ void renderUI(const float* S,const float* Brain,const float* I,unsigned int* Pixels,int width,int height) {
 int ix=(int)(blockIdx.x*blockDim.x+threadIdx.x);int iy=(int)(blockIdx.y*blockDim.y+threadIdx.y);if(ix>=width||iy>=height)return;
 float factor=(float)height/720.0f;float x=(float)ix/factor;float y=(float)iy/factor;float vw=(float)width/factor;float cx=vw*0.5f;
 float4 c=unrgba(Pixels[iy*width+ix]);float4 gold=color(0.68f,0.58f,0.39f);float4 ivory=color(0.85f,0.84f,0.75f);float4 dim=color(0.42f,0.46f,0.43f);
 int mode=(int)S[8];float mouseX=(I[2]+1.0f)*vw*0.5f;float mouseY=(I[3]+1.0f)*360.0f;
 if(mode!=0){
  float shade=(1.0f-smooth01(0.0f,125.0f,y))*0.82f+smooth01(570.0f,720.0f,y)*0.6f;
  c=blend(c,color(0.016f,0.020f,0.022f),shade);
  c=label(c,x,y,28.0f,25.0f,10,1.4f,gold);
  c=number(c,x,y,28.0f,44.0f,(int)S[4],3,2.0f,ivory);
  c=blend(c,dim,glyph(x-69.0f,y-47.0f,47,1.5f));c=number(c,x,y,84.0f,47.0f,(int)S[5],3,1.5f,dim);
  if(y>=70.0f&&y<76.0f&&x>=28.0f&&x<230.0f){c=color(0.16f,0.08f,0.065f);if(x<28.0f+202.0f*S[4]/S[5])c=color(0.62f,0.20f,0.15f);}
  if(y>=81.0f&&y<83.0f&&x>=28.0f&&x<230.0f){c=color(0.12f,0.14f,0.13f);if(x<28.0f+202.0f*(1.0f-S[13]/2.1f))c=color(0.38f,0.49f,0.44f);}
  int minutes=(int)S[6]/60;int seconds=(int)S[6]%60;
  c=number(c,x,y,cx-48.0f,27.0f,minutes,2,2.8f,ivory);c=blend(c,gold,glyph(x-(cx-9.0f),y-27.0f,58,2.8f));c=number(c,x,y,cx+12.0f,27.0f,seconds,2,2.8f,ivory);
  c=centered(c,x,y,cx,57.0f,6,1.15f,dim);
  c=label(c,x,y,vw-129.0f,26.0f,11,1.4f,gold);c=number(c,x,y,vw-128.0f,45.0f,(int)S[12],5,2.0f,ivory);
  c=label(c,x,y,28.0f,672.0f,12,1.8f,gold);c=number(c,x,y,65.0f,672.0f,(int)S[10],2,1.8f,ivory);
  c=label(c,x,y,111.0f,675.0f,63,1.2f,dim);c=number(c,x,y,163.0f,675.0f,(int)S[9],3,1.2f,ivory);
  if(y>=710.0f&&y<713.0f&&x>=28.0f&&x<vw-28.0f){c=color(0.14f,0.14f,0.11f);if(x<28.0f+(vw-56.0f)*S[9]/S[11])c=gold;}
  for(int k=0;k<3;k++){
   float bx=cx+(float)(k-1)*90.0f;float cooldown=k==0?S[13]/2.1f:(k==1?S[17]/0.95f:S[20]/7.0f);
   c=panel(c,x,y,bx,655.0f,42.0f,36.0f,cooldown>0.0f?0.5f:1.0f);
   if(y>=637.0f&&y<673.0f&&fabsf(x-bx)<20.0f&&y>673.0f-cooldown*36.0f)c=blend(c,color(0.12f,0.14f,0.14f),0.7f);
   c=centered(c,x,y,bx,650.0f,60+k,k==0?0.9f:1.3f,cooldown>0.0f?dim:ivory);
   c=centered(c,x,y,bx,682.0f,13+k,1.0f,dim);
  }
  int status=S[45]<0.5f?18:(Brain[0]<1.0f?16:17);
  c=label(c,x,y,vw-203.0f,657.0f,status,1.2f,gold);c=label(c,x,y,vw-203.0f,678.0f,19,1.0f,dim);
  c=number(c,x,y,vw-144.0f,678.0f,(int)fmaxf(1.0f,Brain[13]),2,1.0f,ivory);
  // Cursor is drawn in CUDA too; system cursor is hidden once WebGPU is ready.
  if(mode==1){float d=fabsf(len2(x-mouseX,y-mouseY)-6.0f)-0.55f;c=blend(c,ivory,ink(d,1.0f)*0.65f);}
 }
 if(mode==0){
  c=blend(c,color(0.012f,0.018f,0.021f),0.66f);
  float sx=x-cx;float sy=y-152.0f;float sigil=fminf(fabsf(len2(sx,sy)-33.0f),fabsf(len2(sx,sy)-38.0f))-0.6f;
  sigil=fminf(sigil,segment(sx,sy,0.0f,-49.0f,0.0f,47.0f)-0.7f);
  sigil=fminf(sigil,segment(sx,sy,-25.0f,22.0f,0.0f,-25.0f)-0.6f);sigil=fminf(sigil,segment(sx,sy,0.0f,-25.0f,25.0f,22.0f)-0.6f);
  c=blend(c,gold,ink(sigil,1.1f)*0.85f);
  float titleScale=fminf(1.28f,(vw-46.0f)/(float)TITLE_W);
  float titleX=(x-cx)/titleScale+(float)TITLE_W*0.5f;float titleY=(y-227.0f)/titleScale;
  c=blend(c,color(0.82f,0.80f,0.68f),titleMask(titleX,titleY));
  c=centered(c,x,y,cx,315.0f,0,vw<700.0f?1.4f:1.85f,gold);
  c=centered(c,x,y,cx,381.0f,2,1.3f,ivory);c=centered(c,x,y,cx,404.0f,3,1.3f,dim);
  bool hover=fabsf(mouseX-cx)<151.0f&&fabsf(mouseY-473.0f)<25.0f;
  c=panel(c,x,y,cx,473.0f,302.0f,51.0f,hover?1.6f:1.0f);
  c=centered(c,x,y,cx,466.0f,4,1.8f,hover?ivory:gold);c=centered(c,x,y,cx,515.0f,5,1.0f,dim);
  c=centered(c,x,y,cx,579.0f,7,vw<700.0f?1.0f:1.25f,dim);c=centered(c,x,y,cx,600.0f,8,vw<700.0f?1.0f:1.25f,dim);
  c=centered(c,x,y,cx,647.0f,6,1.15f,gold);c=centered(c,x,y,cx,687.0f,9,0.9f,dim);
 }
 if(mode==2||mode==3||mode==4||mode==5){
  c=blend(c,color(0.009f,0.013f,0.015f),0.84f);
  if(mode==3){
   c=centered(c,x,y,cx,150.0f,21,vw<850.0f?2.6f:3.2f,ivory);c=centered(c,x,y,cx,192.0f,22,vw<850.0f?1.0f:1.2f,dim);
   for(int k=0;k<3;k++){
    float bx=vw<850.0f?cx:cx+(float)(k-1)*280.0f;float by=vw<850.0f?282.0f+(float)k*133.0f:390.0f;
    float ww=vw<850.0f?vw-40.0f:254.0f;float hh=vw<850.0f?116.0f:234.0f;
    bool hover=fabsf(mouseX-bx)<ww*0.5f&&fabsf(mouseY-by)<hh*0.5f;
    c=panel(c,x,y,bx,by,ww,hh,hover?1.8f:0.8f);int kind=((int)S[10]*3+k)%6;
    float iconx=vw<850.0f?bx-ww*0.5f+42.0f:bx;float icony=vw<850.0f?by:by-62.0f;c=relic(c,x-iconx,y-icony,kind,gold);
    float textx=vw<850.0f?bx+18.0f:bx;float texty=vw<850.0f?by-28.0f:by-9.0f;
    c=centered(c,x,y,textx,texty,23+kind,vw<850.0f?1.5f:1.85f,ivory);
    c=centered(c,x,y,textx,texty+29.0f,29+kind,vw<850.0f?0.95f:1.15f,dim);
    float keyy=vw<850.0f?by+31.0f:by+73.0f;c=label(c,x,y,textx-27.0f,keyy,35,1.1f,gold);c=number(c,x,y,textx+17.0f,keyy,k+1,1,1.1f,ivory);
   }
  }else if(mode==2){
   c=centered(c,x,y,cx,210.0f,36,vw<700.0f?2.5f:3.6f,ivory);c=centered(c,x,y,cx,283.0f,37,1.5f,gold);
   c=centered(c,x,y,cx,366.0f,51,vw<700.0f?1.0f:1.35f,dim);c=centered(c,x,y,cx,400.0f,52,vw<700.0f?1.0f:1.35f,dim);
   c=centered(c,x,y,cx,434.0f,53,vw<700.0f?1.0f:1.35f,dim);c=centered(c,x,y,cx,501.0f,57,1.2f,gold);
  }else{
   c=centered(c,x,y,cx,210.0f,mode==4?39:40,4.0f,ivory);c=centered(c,x,y,cx,276.0f,38,vw<700.0f?1.0f:1.3f,dim);
   c=number(c,x,y,cx-46.0f,333.0f,(int)S[6]/60,2,2.5f,ivory);c=blend(c,gold,glyph(x-(cx-11.0f),y-333.0f,58,2.5f));c=number(c,x,y,cx+12.0f,333.0f,(int)S[6]%60,2,2.5f,ivory);
   c=centered(c,x,y,cx-65.0f,383.0f,11,1.3f,gold);c=number(c,x,y,cx-4.0f,383.0f,(int)S[12],5,1.3f,ivory);
   c=centered(c,x,y,cx,446.0f,41,vw<700.0f?1.0f:1.3f,dim);c=centered(c,x,y,cx,516.0f,42,1.7f,gold);
  }
 }
 if(S[47]>0.5f&&mode!=0&&mode!=3){
  // Learning telemetry is intentionally text-only. The old large backing panel
  // could dominate the playfield (and exposed a bad rectangular overlay on
  // some WebGPU implementations). Keep the diagnostic useful without touching
  // a large region of the scene framebuffer.
  float bx=vw>900.0f?vw-206.0f:cx;float by=276.0f;
  c=label(c,x,y,bx-151.0f,by-121.0f,43,1.8f,ivory);
  for(int k=0;k<6;k++){
   float val=Brain[0];if(k==1)val=Brain[1];if(k==2)val=Brain[2]*10000.0f;if(k==3)val=Brain[3]*10000.0f;if(k==4)val=Brain[4]*100.0f;if(k==5)val=Brain[12];
   float yy=by-79.0f+(float)k*29.0f;c=label(c,x,y,bx-151.0f,yy,44+k,1.1f,dim);
   if(k==2||k==3){c=number(c,x,y,bx+82.0f,yy,(int)val/10000,1,1.0f,ivory);c=blend(c,ivory,glyph(x-bx-88.0f,y-yy,46,1.0f));c=number(c,x,y,bx+94.0f,yy,(int)val%10000,4,1.0f,ivory);}
   else c=number(c,x,y,bx+82.0f,yy,(int)val,6,1.0f,ivory);
  }
  c=centered(c,x,y,bx,by+116.0f,50,0.8f,gold);
 }
 Pixels[iy*width+ix]=rgba(c);
}

// ===== AUDIO =====
// Audio waveforms are CUDA-generated as well. WebAudio only plays these buffers.
__global__ void synthAudio(float* Audio,int count,int sampleRate) {
 int i=(int)(blockIdx.x*blockDim.x+threadIdx.x);if(i>=count)return;
 int section=i/sampleRate;float t=(float)(i%sampleRate)/(float)sampleRate;float value=0.0f;float noise=hashf((float)i)-0.5f;
 if(section==0)value=(noise*1.2f+sinf(t*PI*2.0f*(115.0f-50.0f*t)))*expf(-t*38.0f)*0.40f;
 if(section==1)value=(noise*0.75f+sinf(t*PI*2.0f*(430.0f-270.0f*t))*0.15f)*expf(-t*14.0f)*0.40f;
 if(section==2)value=(noise*0.5f+sinf(t*PI*2.0f*58.0f))*expf(-t*10.0f)*0.23f;
 if(section==3)value=(sinf(t*PI*2.0f*880.0f)+0.35f*sinf(t*PI*2.0f*1320.0f))*expf(-t*18.0f)*0.11f;
 if(section==4)value=(sinf(t*PI*2.0f*220.0f)+sinf(t*PI*2.0f*330.0f)*0.6f+sinf(t*PI*2.0f*440.0f)*0.4f)*expf(-t*3.5f)*(1.0f-expf(-t*40.0f))*0.14f;
 if(section==5)value=(noise*0.5f+sinf(t*PI*2.0f*(150.0f+220.0f*t))*0.15f)*expf(-t*13.0f)*0.20f;
 if(section==6)value=(sinf(t*PI*2.0f*(72.0f-28.0f*t))+noise*0.12f)*expf(-t*2.8f)*0.25f;
 if(section==7)value=(sinf(t*PI*2.0f*110.0f)+sinf(t*PI*2.0f*165.0f)*0.3f+noise*0.2f)*expf(-t*5.0f)*0.25f;
 if(section>=8){
  float at=(float)(i-8*sampleRate)/(float)sampleRate;
  float swell=0.7f+0.3f*sinf(at*PI*0.25f);
  value=(sinf(at*PI*2.0f*55.0f)*0.20f+sinf(at*PI*2.0f*82.5f)*0.10f+sinf(at*PI*2.0f*110.125f)*0.06f)*swell+noise*0.008f;
 }
 Audio[i]=fmaxf(-1.0f,fminf(1.0f,value));
}
