// CPU execution harness for the EXACT authored kernels, not an alternate game.
// Build: g++ -x c++ -std=c++17 -O2 -fopenmp tests/native_harness.cu -o /tmp/nocturne-native
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include <algorithm>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <iomanip>
#define __device__
#define __global__
#define __constant__ const
struct Index {unsigned int x=0,y=0,z=0;};
thread_local Index threadIdx,blockIdx,blockDim,gridDim;
struct float4 {float x,y,z,w;};
float4 make_float4(float x,float y,float z,float w){return{x,y,z,w};}
float4 operator+(float4 a,float4 b){return{a.x+b.x,a.y+b.y,a.z+b.z,a.w+b.w};}
float4 operator-(float4 a,float4 b){return{a.x-b.x,a.y-b.y,a.z-b.z,a.w-b.w};}
float4 operator*(float4 a,float b){return{a.x*b,a.y*b,a.z*b,a.w*b};}
float4 operator*(float b,float4 a){return a*b;}
float4 operator/(float4 a,float b){return{a.x/b,a.y/b,a.z/b,a.w/b};}
#include "../kernels/common.cu"
#include "../kernels/game.cu"
#include "../kernels/learning.cu"
#include "../kernels/render.cu"
#include "../kernels/ui.cu"
#include "../kernels/audio.cu"

template<class F>void dispatch1(int count,F f){for(int i=0;i<count;i++){threadIdx={unsigned(i%64),0,0};blockIdx={unsigned(i/64),0,0};blockDim={64,1,1};gridDim={unsigned((count+63)/64),1,1};f();}}
template<class F>void dispatch2(int width,int height,F f){
 #pragma omp parallel for schedule(dynamic,4)
 for(int y=0;y<height;y++)for(int x=0;x<width;x++){threadIdx={unsigned(x%8),unsigned(y%8),0};blockIdx={unsigned(x/8),unsigned(y/8),0};blockDim={8,8,1};gridDim={unsigned((width+7)/8),unsigned((height+7)/8),1};f();}}
void scalar(){threadIdx={0,0,0};blockIdx={0,0,0};blockDim={1,1,1};gridDim={1,1,1};}
struct Simulation {
 std::vector<float>S=std::vector<float>(128),I=std::vector<float>(32),E=std::vector<float>(ENEMIES*ES),Old=std::vector<float>(ENEMIES*ES),P=std::vector<float>(BULLETS*BS),W=std::vector<float>(PARAMS),M=std::vector<float>(PARAMS),V=std::vector<float>(PARAMS),G=std::vector<float>(640),Brain=std::vector<float>(32),R=std::vector<float>(REPLAY*RS),Work=std::vector<float>(BATCH*WS),Grad=std::vector<float>(PARAMS);
 float aspect=16.0f/9.0f;float dt=1.0f/60.0f;
 Simulation(){dispatch1(640,[&]{initialise(S.data(),W.data(),M.data(),V.data(),G.data(),Brain.data(),1788);});scalar();newRun(S.data(),1788);I[2]=.3f;}
 void tick(){scalar();stepWorld(S.data(),E.data(),I.data(),G.data(),aspect,dt);
  dispatch1(BULLETS,[&]{stepProjectiles(S.data(),P.data(),dt);});E.swap(Old);
  dispatch1(ENEMIES,[&]{stepEnemies(S.data(),Old.data(),E.data(),P.data(),G.data(),Brain.data(),dt,aspect);});
  scalar();evolvePopulation(S.data(),G.data(),Brain.data());recordExperience(S.data(),E.data(),I.data(),R.data(),Brain.data());
  dispatch1(BATCH,[&]{prepareBatch(S.data(),Brain.data(),R.data(),Work.data());});dispatch1(BATCH,[&]{forwardBatch(S.data(),Brain.data(),W.data(),Work.data());});dispatch1(BATCH,[&]{backwardBatch(S.data(),Brain.data(),W.data(),Work.data());});
  dispatch1(PARAMS,[&]{computeGradient(S.data(),Brain.data(),Work.data(),Grad.data());});dispatch1(PARAMS,[&]{updateWeights(S.data(),Brain.data(),Grad.data(),W.data(),M.data(),V.data());});scalar();inferPlayer(S.data(),R.data(),W.data(),Brain.data());
 }
 void start(){I[8]=1;tick();I[8]=0;tick();}
 void render(const std::string&file,int width=1280,int height=720){
  std::vector<int>tiles(((width+31)/32)*((height+31)/32)*64);std::vector<unsigned int>pixels(width*height);
  dispatch1(((width+31)/32)*((height+31)/32),[&]{buildTiles(S.data(),E.data(),P.data(),tiles.data(),width,height);});
  dispatch2(width,height,[&]{renderWorld(S.data(),E.data(),P.data(),tiles.data(),pixels.data(),width,height);});
  dispatch2(width,height,[&]{renderUI(S.data(),Brain.data(),I.data(),pixels.data(),width,height);});
  std::ofstream o(file,std::ios::binary);o<<"P6\n"<<width<<" "<<height<<"\n255\n";for(auto p:pixels){char b[3]={char(p&255),char((p>>8)&255),char((p>>16)&255)};o.write(b,3);}std::cout<<"Rendered "<<file<<"\n";
 }
};
void require(bool cond,const char* name){if(!cond)throw std::runtime_error(name);std::cout<<"PASS "<<name<<"\n";}
void finite(const std::vector<float>&v,const char*name){require(std::all_of(v.begin(),v.end(),[](float x){return std::isfinite(x);}),name);}
float loss(Simulation&g){dispatch1(BATCH,[&]{forwardBatch(g.S.data(),g.Brain.data(),g.W.data(),g.Work.data());});float r=0;for(int j=0;j<BATCH;j++){float ex=g.Work[j*WS+18]-g.Work[j*WS+16],ey=g.Work[j*WS+19]-g.Work[j*WS+17];r+=(ex*ex+ey*ey)*0.5f/BATCH;}return r;}
int main(int argc,char**argv){try{
 Simulation g;
 if(argc>1&&std::string(argv[1])=="title"){g.render(argc>2?argv[2]:"title.ppm");return 0;}
 require(g.S[8]==0&&g.S[4]==100,"title initialization");g.start();require(g.S[8]==1,"start and state reset");
 const float before=g.S[0];g.I[0]=1;for(int i=0;i<30;i++)g.tick();require(g.S[0]>before+60,"WASD movement");g.I[0]=0;
 g.I[9]=1;g.tick();g.I[9]=0;const float paused=g.S[6];for(int i=0;i<5;i++)g.tick();require(g.S[8]==2&&g.S[6]==paused,"pause freezes simulation");g.I[9]=1;g.tick();g.I[9]=0;g.tick();require(g.S[8]==1,"resume");
 // Inject a reproducible encounter; all hit tests, damage and death are actual kernels.
 g.S[0]=0;g.S[1]=0;g.S[25]=0;g.S[26]=0;g.E.assign(g.E.size(),0);g.P.assign(g.P.size(),0);g.S[15]=100;g.S[31]=0;
 g.E[0]=55;g.E[1]=0;g.E[4]=35;g.E[5]=35;g.E[13]=0;g.E[14]=-1;g.E[10]=5;
 g.I[2]=.5f;g.I[3]=0;g.I[5]=1;g.tick();g.I[5]=0;g.tick();require(g.S[12]>=1,"scythe damage and kill accounting");
 g.E[0]=g.S[0];g.E[1]=g.S[1];g.tick();g.tick();require(g.S[9]>=3,"soul pickup grants experience");
 g.S[9]=g.S[11];g.E[19]=1;float killsBeforeUpgrade=g.S[12];g.tick();require(g.S[8]==3,"level-up opens relic choice");g.I[10]=1;float power=g.S[32];g.tick();g.I[10]=0;require(g.S[8]==1&&g.S[32]>power,"relic upgrade changes combat stats");g.tick();require(g.S[12]==killsBeforeUpgrade+1,"relic transitions consume combat feedback exactly once");
 g.E.assign(g.E.size(),0);g.S[38]=0;g.E[20]=11;float hp=g.S[4];g.tick();require(g.S[4]<hp,"enemy damage reduces player life");require(g.E[23]==11.0f,"enemy fitness receives actual damage credit");
 g.S[4]=1;g.S[38]=0;g.E[20]=11;g.tick();require(g.S[8]==4,"death ends the run");g.I[8]=1;g.tick();g.I[8]=0;g.tick();require(g.S[8]==1&&g.S[4]==100&&g.S[12]==0,"restart clears the run");
 auto initial=g.W;int trustedTicks=0;float peakTrust=0;g.S[5]=g.S[4]=100000; // test invulnerability only; not a game feature
 for(int t=0;t<3600;t++){
  float a=(float)t/60.0f*.65f;g.I[0]=cosf(a);g.I[1]=sinf(a);g.I[2]=.6f*cosf(a+1.3f);g.I[3]=.6f*sinf(a+1.3f);g.I[5]=t%120<15;g.I[7]=t%420<2;
  if(g.S[8]==3)g.I[10]=2;else g.I[10]=0;g.tick();if(g.Brain[4]>0.01f)trustedTicks++;peakTrust=std::max(peakTrust,g.Brain[4]);
 }
 require(g.Brain[0]>100,"real online optimizer steps");require(initial!=g.W,"weights change during play");require(g.Brain[1]>400,"future labels mature from observed motion");finite(g.W,"finite weights");finite(g.M,"finite optimizer momentum");finite(g.V,"finite optimizer variance");finite(g.Brain,"finite training metrics");finite(g.E,"finite enemy state");
 auto frozen=g.W;g.S[45]=0;float freezeTime=g.S[6];for(int t=0;t<120;t++){g.I[10]=g.S[8]==3?2:0;g.tick();}require(frozen==g.W&&g.S[6]>freezeTime+1.5f,"freeze learning holds weights while gameplay continues");g.S[45]=1;
 // Independent finite-difference derivative check, away from gradient clipping.
 Simulation grad;for(int i=0;i<PARAMS;i++)grad.W[i]=sinf(float(i)*1.37f)*.05f;grad.S[8]=1;grad.S[51]=1;grad.S[7]=120;grad.Brain[10]=100;grad.S[45]=1;
 for(int b=0;b<BATCH;b++){for(int f=0;f<16;f++)grad.Work[b*WS+f]=.3f*sinf(float(b*16+f));grad.Work[b*WS+16]=.15f;grad.Work[b*WS+17]=-.07f;}
 loss(grad);dispatch1(BATCH,[&]{backwardBatch(grad.S.data(),grad.Brain.data(),grad.W.data(),grad.Work.data());});dispatch1(PARAMS,[&]{computeGradient(grad.S.data(),grad.Brain.data(),grad.Work.data(),grad.Grad.data());});
 float worst=0;for(int i=0;i<PARAMS;i++){float v=grad.W[i],eps=.001f;grad.W[i]=v+eps;float plus=loss(grad);grad.W[i]=v-eps;float minus=loss(grad);grad.W[i]=v;float numerical=(plus-minus)/(2*eps);worst=std::max(worst,std::fabs(numerical-grad.Grad[i]));}
 std::cout<<"Gradient maximum absolute error "<<worst<<"\n";require(worst<.0002,"backprop matches numerical differentiation");
 // Force lineage fitness coverage to make selection itself deterministic.
 scalar();g.S[7]=1200;for(int sp=0;sp<5;sp++)for(int v=0;v<8;v++){int b=(sp*8+v)*16;g.G[b+6]=float(v)*.2f;g.G[b+7]=3;}
 g.S[51]=1;g.S[8]=1;float generations=g.Brain[12];evolvePopulation(g.S.data(),g.G.data(),g.Brain.data());require(g.Brain[12]>generations,"fitness-driven lineage mutation");
 // Deterministic learned motion, no human-player claim. Independent scores are prequential.
 std::cout<<"METRICS {\"steps\":"<<g.Brain[0]<<",\"observations\":"<<g.Brain[1]<<",\"neuralMSE\":"<<g.Brain[2]<<",\"velocityMSE\":"<<g.Brain[3]<<",\"trust\":"<<g.Brain[4]<<",\"kills\":"<<g.S[12]<<",\"alive\":"<<g.S[27]<<",\"generation\":"<<g.Brain[13]<<",\"trustedTicks\":"<<trustedTicks<<",\"peakTrust\":"<<peakTrust<<"}\n";
 std::vector<float>audio(22050*16);dispatch1((int)audio.size(),[&]{synthAudio(audio.data(),(int)audio.size(),22050);});finite(audio,"finite CUDA-generated sound bank");require(std::all_of(audio.begin(),audio.end(),[](float v){return std::fabs(v)<=1.0f;}),"sound bank stays inside PCM bounds");
 if(argc>1&&std::string(argv[1])=="render"){
  g.S[5]=125;g.S[4]=94;g.S[47]=0;g.S[8]=1;g.render(argc>2?argv[2]:"game.ppm");g.S[8]=3;g.render("nocturne_relics.ppm");
 }
 return 0;
 }catch(const std::exception&e){std::cerr<<"FAIL "<<e.what()<<"\n";return 1;}}
