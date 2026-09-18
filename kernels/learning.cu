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
