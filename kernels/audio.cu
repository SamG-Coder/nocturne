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
