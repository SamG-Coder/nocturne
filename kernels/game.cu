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
