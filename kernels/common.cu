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
#define TILE 32
#define TILE_CAP 128
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
