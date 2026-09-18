// CUDA WebShader 0.1.0. Generated from kernel renderWorld.
@group(0) @binding(0) var<storage, read> b_S: array<f32>;
@group(0) @binding(1) var<storage, read> b_E: array<f32>;
@group(0) @binding(2) var<storage, read> b_P: array<f32>;
@group(0) @binding(3) var<storage, read> b_Tiles: array<i32>;
@group(0) @binding(4) var<storage, read_write> b_Pixels: array<u32>;
struct CWParams {
  p_width: i32,
  p_height: i32,
  cw_pad_8: u32,
  cw_pad_12: u32,
}
@group(0) @binding(5) var<uniform> cw_params: CWParams;
const cw_block_size: vec3<u32> = vec3<u32>(8u, 8u, 1u);

fn cw_divide_f32(a: f32, b: f32) -> f32 { let q = a / b; if ((bitcast<u32>(q) & 0x7f800000u) == 0x7f800000u || (bitcast<u32>(q) & 0x7fffffffu) == 0u || (bitcast<u32>(b) & 0x7f800000u) == 0x7f800000u) { return q; } let residual = fma(-q, b, a); return q + residual / b; }

alias cw_f64 = vec2<u32>;
fn cw_d_shl(a: vec2<u32>, n: u32) -> vec2<u32> {
  if(n == 0u) { return a; }
  if(n >= 64u) { return vec2<u32>(0u); }
  if(n >= 32u) { return vec2<u32>(0u, a.x << (n - 32u)); }
  return vec2<u32>(a.x << n, (a.y << n) | (a.x >> (32u - n)));
}
fn cw_d_shr(a: vec2<u32>, n: u32) -> vec2<u32> {
  if(n == 0u) { return a; }
  if(n >= 64u) { return vec2<u32>(0u); }
  if(n >= 32u) { return vec2<u32>(a.y >> (n - 32u), 0u); }
  return vec2<u32>((a.x >> n) | (a.y << (32u - n)), a.y >> n);
}
fn cw_d_jam(a: vec2<u32>, n: u32) -> vec2<u32> {
  let shifted = cw_d_shr(a, n);
  return shifted | vec2<u32>(select(0u, 1u, any(cw_d_shl(shifted, n) != a)), 0u);
}
fn cw_d_uadd(a: vec2<u32>, b: vec2<u32>) -> vec2<u32> {
  let low = a.x + b.x;
  return vec2<u32>(low, a.y + b.y + select(0u, 1u, low < a.x));
}
fn cw_d_usub(a: vec2<u32>, b: vec2<u32>) -> vec2<u32> {
  return vec2<u32>(a.x - b.x, a.y - b.y - select(0u, 1u, a.x < b.x));
}
fn cw_d_uless(a: vec2<u32>, b: vec2<u32>) -> bool {
  return a.y < b.y || (a.y == b.y && a.x < b.x);
}
fn cw_d_nan(a: cw_f64) -> bool { return (a.y & 2147483647u) > 2146435072u || ((a.y & 2147483647u) == 2146435072u && a.x != 0u); }
fn cw_d_inf(a: cw_f64) -> bool { return (a.y & 2147483647u) == 2146435072u && a.x == 0u; }
fn cw_d_zero(a: cw_f64) -> bool { return (a.y & 2147483647u) == 0u && a.x == 0u; }
fn cw_d_neg(a: cw_f64) -> cw_f64 { return a ^ vec2<u32>(0u, 2147483648u); }
struct CWDoubleParts { significand: vec2<u32>, exponent: i32, }
fn cw_d_parts(a: cw_f64) -> CWDoubleParts {
  let raw = (a.y >> 20u) & 2047u;
  var s = vec2<u32>(a.x, a.y & 1048575u);
  var e = i32(raw) - 1023i;
  if(raw != 0u) { s.y |= 1048576u; }
  else {
    e = -1022i;
    if(any(s != vec2<u32>(0u))) {
      loop { if((s.y & 1048576u) != 0u) { break; } s = cw_d_shl(s, 1u); e--; }
    }
  }
  return CWDoubleParts(s,e);
}
// Input has its leading bit at bit 55 and three guard/round/sticky bits.
fn cw_d_pack(sign: u32, exponent: i32, value: vec2<u32>) -> cw_f64 {
  var e = exponent; var v = value;
  if(e < -1022i) { v = cw_d_jam(v, u32(-1022i-e)); e = -1022i; }
  let tail = v.x & 7u;
  var s = cw_d_shr(v, 3u);
  if(tail > 4u || (tail == 4u && (s.x & 1u) != 0u)) { s = cw_d_uadd(s,vec2<u32>(1u,0u)); }
  if((s.y & 2097152u) != 0u) { s = cw_d_shr(s,1u); e++; }
  if(e > 1023i) { return vec2<u32>(0u,sign | 2146435072u); }
  let field = select(0u, u32(e+1023i), (s.y & 1048576u) != 0u);
  return vec2<u32>(s.x, sign | (field << 20u) | (s.y & 1048575u));
}
fn cw_d_from_f32(a: f32) -> cw_f64 {
  let bits = bitcast<u32>(a); let sign = bits & 2147483648u;
  let field = (bits >> 23u) & 255u; var mantissa = bits & 8388607u;
  if(field == 255u) { return vec2<u32>(0u,sign | 2146435072u | select(0u,524288u,mantissa != 0u)); }
  if(field == 0u && mantissa == 0u) { return vec2<u32>(0u,sign); }
  var e = i32(field)-127i;
  if(field == 0u) { e = -126i; loop { if((mantissa & 8388608u) != 0u) { break; } mantissa <<= 1u; e--; } }
  let s = cw_d_shl(vec2<u32>(mantissa & 8388607u,0u),29u);
  return vec2<u32>(s.x,sign | (u32(e+1023i) << 20u) | s.y);
}
fn cw_d_from_u32(a: u32) -> cw_f64 {
  if(a == 0u) { return vec2<u32>(0u); }
  let e = 31u-countLeadingZeros(a); let s = cw_d_shl(vec2<u32>(a,0u),52u-e);
  return vec2<u32>(s.x,((e+1023u) << 20u) | (s.y & 1048575u));
}
fn cw_d_from_i32(a: i32) -> cw_f64 {
  if(a < 0i) { return cw_d_neg(cw_d_from_u32(0u-u32(a))); }
  return cw_d_from_u32(u32(a));
}
fn cw_d_to_f32(a: cw_f64) -> f32 {
  let sign = a.y & 2147483648u;
  if(cw_d_nan(a)) { return bitcast<f32>(sign | 2143289344u); }
  if(cw_d_inf(a)) { return bitcast<f32>(sign | 2139095040u); }
  if(cw_d_zero(a)) { return bitcast<f32>(sign); }
  let p = cw_d_parts(a); var e = p.exponent;
  let shift = 29u + u32(max(-126i-e,0i));
  // Keep three rounding bits while reducing the 53-bit significand to 24 bits.
  let v = cw_d_jam(p.significand,shift-3u); let tail = v.x & 7u;
  var s = cw_d_shr(v,3u).x;
  if(tail > 4u || (tail == 4u && (s & 1u) != 0u)) { s++; }
  e = max(e,-126i);
  if(s >= 16777216u) { s >>= 1u; e++; }
  if(e > 127i) { return bitcast<f32>(sign | 2139095040u); }
  let field = select(0u,u32(e+127i),s >= 8388608u);
  return bitcast<f32>(sign | (field << 23u) | (s & 8388607u));
}
fn cw_d_u64_to_f32(a: vec2<u32>) -> f32 {
  if(all(a == vec2<u32>(0u))) { return 0.0f; }
  var e = select(31u-countLeadingZeros(a.x),63u-countLeadingZeros(a.y),a.y != 0u);
  var v: vec2<u32>;
  if(e > 26u) { v = cw_d_jam(a,e-26u); } else { v = cw_d_shl(a,26u-e); }
  let tail = v.x & 7u; var s = v.x >> 3u;
  if(tail > 4u || (tail == 4u && (s & 1u) != 0u)) { s++; }
  if(s >= 16777216u) { s >>= 1u; e++; }
  return bitcast<f32>(((e+127u) << 23u) | (s & 8388607u));
}
fn cw_d_eq(a: cw_f64,b: cw_f64) -> bool { return !cw_d_nan(a) && !cw_d_nan(b) && (all(a == b) || (cw_d_zero(a) && cw_d_zero(b))); }
fn cw_d_lt(a: cw_f64,b: cw_f64) -> bool {
  if(cw_d_nan(a) || cw_d_nan(b) || cw_d_eq(a,b)) { return false; }
  let sa = a.y >> 31u; let sb = b.y >> 31u;
  if(sa != sb) { return sa != 0u; }
  return select(cw_d_uless(a,b),cw_d_uless(b,a),sa != 0u);
}
fn cw_d_le(a: cw_f64,b: cw_f64) -> bool { return cw_d_lt(a,b) || cw_d_eq(a,b); }
fn cw_d_add(a: cw_f64,b: cw_f64) -> cw_f64 {
  if(cw_d_nan(a) || cw_d_nan(b) || (cw_d_inf(a) && cw_d_inf(b) && ((a.y ^ b.y) >> 31u) != 0u)) { return vec2<u32>(0u,2146959360u); }
  if(cw_d_inf(a)) { return a; } if(cw_d_inf(b)) { return b; }
  if(cw_d_zero(a) && cw_d_zero(b)) { return vec2<u32>(0u,(a.y & b.y) & 2147483648u); }
  if(cw_d_zero(a)) { return b; } if(cw_d_zero(b)) { return a; }
  let pa = cw_d_parts(a); let pb = cw_d_parts(b);
  var x = cw_d_shl(pa.significand,3u); var y = cw_d_shl(pb.significand,3u);
  var e = max(pa.exponent,pb.exponent); var sign = a.y & 2147483648u;
  x = cw_d_jam(x,u32(e-pa.exponent)); y = cw_d_jam(y,u32(e-pb.exponent));
  var sum: vec2<u32>;
  if(((a.y ^ b.y) >> 31u) == 0u) {
    sum = cw_d_uadd(x,y);
    if((sum.y & 16777216u) != 0u) { sum = cw_d_jam(sum,1u); e++; }
  } else {
    if(cw_d_uless(x,y)) { sum = cw_d_usub(y,x); sign = b.y & 2147483648u; }
    else { sum = cw_d_usub(x,y); }
    if(all(sum == vec2<u32>(0u))) { return vec2<u32>(0u); }
    loop { if((sum.y & 8388608u) != 0u) { break; } sum = cw_d_shl(sum,1u); e--; }
  }
  return cw_d_pack(sign,e,sum);
}
fn cw_d_sub(a: cw_f64,b: cw_f64) -> cw_f64 { return cw_d_add(a,cw_d_neg(b)); }
fn cw_d_mul(a: cw_f64,b: cw_f64) -> cw_f64 {
  let sign = (a.y ^ b.y) & 2147483648u;
  if(cw_d_nan(a) || cw_d_nan(b) || (cw_d_inf(a) && cw_d_zero(b)) || (cw_d_inf(b) && cw_d_zero(a))) { return vec2<u32>(0u,2146959360u); }
  if(cw_d_inf(a) || cw_d_inf(b)) { return vec2<u32>(0u,sign | 2146435072u); }
  if(cw_d_zero(a) || cw_d_zero(b)) { return vec2<u32>(0u,sign); }
  let pa = cw_d_parts(a); let pb = cw_d_parts(b);
  if(all(pa.significand == vec2<u32>(0u,1048576u))) { return cw_d_pack(sign,pa.exponent+pb.exponent,cw_d_shl(pb.significand,3u)); }
  if(all(pb.significand == vec2<u32>(0u,1048576u))) { return cw_d_pack(sign,pa.exponent+pb.exponent,cw_d_shl(pa.significand,3u)); }
  var product = vec4<u32>(0u); var term = vec4<u32>(pa.significand,0u,0u); var multiplier = pb.significand;
  for(var i = 0u; i < 53u; i++) {
    if((multiplier.x & 1u) != 0u) {
      var carry = 0u;
      for(var j = 0u; j < 4u; j++) {
        let p = product[j]; let s = p + term[j]; let t = s + carry;
        carry = select(0u,1u,s < p || t < s); product[j] = t;
      }
    }
    term = vec4<u32>(term.x << 1u,(term.y << 1u) | (term.x >> 31u),(term.z << 1u) | (term.y >> 31u),(term.w << 1u) | (term.z >> 31u));
    multiplier = cw_d_shr(multiplier,1u);
  }
  let extra = select(0u,1u,(product.w & 512u) != 0u);
  for(var i = 0u; i < 49u+extra; i++) {
    product = vec4<u32>((product.x >> 1u) | (product.y << 31u) | (product.x & 1u),(product.y >> 1u) | (product.z << 31u),(product.z >> 1u) | (product.w << 31u),product.w >> 1u);
  }
  return cw_d_pack(sign,pa.exponent+pb.exponent+i32(extra),product.xy);
}
fn cw_d_div(a: cw_f64,b: cw_f64) -> cw_f64 {
  let sign = (a.y ^ b.y) & 2147483648u;
  if(cw_d_nan(a) || cw_d_nan(b) || (cw_d_inf(a) && cw_d_inf(b)) || (cw_d_zero(a) && cw_d_zero(b))) { return vec2<u32>(0u,2146959360u); }
  if(cw_d_inf(a) || cw_d_zero(b)) { return vec2<u32>(0u,sign | 2146435072u); }
  if(cw_d_zero(a) || cw_d_inf(b)) { return vec2<u32>(0u,sign); }
  let pa = cw_d_parts(a); let pb = cw_d_parts(b); var e = pa.exponent-pb.exponent;
  var remainder = pa.significand; var q = vec2<u32>(0u);
  if(cw_d_uless(remainder,pb.significand)) { remainder = cw_d_shl(remainder,1u); e--; }
  for(var i = 0u; i < 56u; i++) {
    q = cw_d_shl(q,1u);
    if(!cw_d_uless(remainder,pb.significand)) { remainder = cw_d_usub(remainder,pb.significand); q.x |= 1u; }
    if(i < 55u) { remainder = cw_d_shl(remainder,1u); }
  }
  if(any(remainder != vec2<u32>(0u))) { q.x |= 1u; }
  return cw_d_pack(sign,e,q);
}

// Restoring square root: 56 root bits include guard/round/sticky for binary64.
fn cw_d_sqrt(a: cw_f64) -> cw_f64 {
  if(cw_d_nan(a)) { return vec2<u32>(0u,2146959360u); }
  if(cw_d_zero(a)) { return a; }
  if((a.y & 2147483648u) != 0u) { return vec2<u32>(0u,2146959360u); }
  if(cw_d_inf(a)) { return a; }
  let p = cw_d_parts(a);
  let odd = p.exponent & 1i;
  let shift = 58i + odd;
  var root = vec2<u32>(0u);
  var remainder = vec2<u32>(0u);
  for(var i=55i; i>=0i; i--) {
    var pair=0u;
    for(var j=0i; j<2i; j++) {
      let bit=2i*i+j-shift;
      if(bit>=0i && bit<53i) { pair |= ((p.significand[u32(bit)/32u] >> (u32(bit)%32u)) & 1u) << u32(j); }
    }
    remainder=cw_d_shl(remainder,2u); remainder.x |= pair;
    var trial=cw_d_shl(root,2u); trial.x |= 1u;
    root=cw_d_shl(root,1u);
    if(!cw_d_uless(remainder,trial)) { remainder=cw_d_usub(remainder,trial); root.x |= 1u; }
  }
  if(any(remainder!=vec2<u32>(0u))) { root.x |= 1u; }
  return cw_d_pack(0u,(p.exponent-odd)/2i,root);
}
fn cw_d_fmin(a: cw_f64,b: cw_f64) -> cw_f64 {
  if(cw_d_nan(a)) { return b; } if(cw_d_nan(b)) { return a; }
  if(cw_d_zero(a) && cw_d_zero(b)) { return vec2<u32>(0u,(a.y | b.y) & 2147483648u); }
  return select(b,a,cw_d_lt(a,b));
}
fn cw_d_fmax(a: cw_f64,b: cw_f64) -> cw_f64 {
  if(cw_d_nan(a)) { return b; } if(cw_d_nan(b)) { return a; }
  if(cw_d_zero(a) && cw_d_zero(b)) { return vec2<u32>(0u,(a.y & b.y) & 2147483648u); }
  return select(a,b,cw_d_lt(a,b));
}

fn f_sat(cw_arg_x: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  return min(1.0f, max(0.0f, v_x));
}
fn f_mixf(cw_arg_a: f32, cw_arg_b: f32, cw_arg_t: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_a: f32 = cw_arg_a;
  var v_b: f32 = cw_arg_b;
  var v_t: f32 = cw_arg_t;
  return (v_a + ((v_b - v_a) * v_t));
}
fn f_len2(cw_arg_x: f32, cw_arg_y: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  return sqrt(((v_x * v_x) + (v_y * v_y)));
}
fn f_frac(cw_arg_x: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  return (v_x - floor(v_x));
}
fn f_hashf(cw_arg_n: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_n: f32 = cw_arg_n;
  return f_frac((sin(((v_n * 127.1f) + 311.7f)) * 43758.5453f), cw_thread, cw_block, cw_grid);
}
fn f_h2(cw_arg_x: f32, cw_arg_y: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  return f_hashf(((v_x * 13.37f) + (v_y * 71.91f)), cw_thread, cw_block, cw_grid);
}
fn f_smooth01(cw_arg_a: f32, cw_arg_b: f32, cw_arg_x: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_a: f32 = cw_arg_a;
  var v_b: f32 = cw_arg_b;
  var v_x: f32 = cw_arg_x;
  var v_t: f32 = f_sat(cw_divide_f32((v_x - v_a), (v_b - v_a)), cw_thread, cw_block, cw_grid);
  return ((v_t * v_t) * (3.0f - (2.0f * v_t)));
}
fn f_noise2(cw_arg_x: f32, cw_arg_y: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_ix: f32 = floor(v_x);
  var v_iy: f32 = floor(v_y);
  var v_fx: f32 = f_frac(v_x, cw_thread, cw_block, cw_grid);
  var v_fy: f32 = f_frac(v_y, cw_thread, cw_block, cw_grid);
  v_fx = ((v_fx * v_fx) * (3.0f - (2.0f * v_fx)));
  v_fy = ((v_fy * v_fy) * (3.0f - (2.0f * v_fy)));
  return f_mixf(f_mixf(f_h2(v_ix, v_iy, cw_thread, cw_block, cw_grid), f_h2((v_ix + 1.0f), v_iy, cw_thread, cw_block, cw_grid), v_fx, cw_thread, cw_block, cw_grid), f_mixf(f_h2(v_ix, (v_iy + 1.0f), cw_thread, cw_block, cw_grid), f_h2((v_ix + 1.0f), (v_iy + 1.0f), cw_thread, cw_block, cw_grid), v_fx, cw_thread, cw_block, cw_grid), v_fy, cw_thread, cw_block, cw_grid);
}
fn f_boxd(cw_arg_x: f32, cw_arg_y: f32, cw_arg_bx: f32, cw_arg_by: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_bx: f32 = cw_arg_bx;
  var v_by: f32 = cw_arg_by;
  var v_qx: f32 = (abs(v_x) - v_bx);
  var v_qy: f32 = (abs(v_y) - v_by);
  return (f_len2(max(v_qx, 0.0f), max(v_qy, 0.0f), cw_thread, cw_block, cw_grid) + min(max(v_qx, v_qy), 0.0f));
}
fn f_segment(cw_arg_x: f32, cw_arg_y: f32, cw_arg_ax: f32, cw_arg_ay: f32, cw_arg_bx: f32, cw_arg_by: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_ax: f32 = cw_arg_ax;
  var v_ay: f32 = cw_arg_ay;
  var v_bx: f32 = cw_arg_bx;
  var v_by: f32 = cw_arg_by;
  var v_vx: f32 = (v_bx - v_ax);
  var v_vy: f32 = (v_by - v_ay);
  var v_t: f32 = f_sat(cw_divide_f32((((v_x - v_ax) * v_vx) + ((v_y - v_ay) * v_vy)), (((v_vx * v_vx) + (v_vy * v_vy)) + 0.0001f)), cw_thread, cw_block, cw_grid);
  return f_len2(((v_x - v_ax) - (v_vx * v_t)), ((v_y - v_ay) - (v_vy * v_t)), cw_thread, cw_block, cw_grid);
}
fn f_obstacle(cw_arg_x: f32, cw_arg_y: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_gx: f32 = floor(cw_divide_f32((v_x + 96.0f), 192.0f));
  var v_gy: f32 = floor(cw_divide_f32((v_y + 96.0f), 192.0f));
  var v_cx: f32 = ((v_gx * 192.0f) + ((f_h2(v_gx, v_gy, cw_thread, cw_block, cw_grid) - 0.5f) * 60.0f));
  var v_cy: f32 = ((v_gy * 192.0f) + ((f_h2(v_gy, (v_gx + 31.0f), cw_thread, cw_block, cw_grid) - 0.5f) * 50.0f));
  if (((f_len2(v_cx, v_cy, cw_thread, cw_block, cw_grid) < 235.0f) || (f_h2((v_gx + 82.0f), v_gy, cw_thread, cw_block, cw_grid) < 0.35f))) {
    return 1000.0f;
  }
  return f_boxd((v_x - v_cx), (v_y - v_cy), 18.0f, 11.0f, cw_thread, cw_block, cw_grid);
}
fn f_color(cw_arg_r: f32, cw_arg_g: f32, cw_arg_b: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec4<f32> {
  var v_r: f32 = cw_arg_r;
  var v_g: f32 = cw_arg_g;
  var v_b: f32 = cw_arg_b;
  return vec4<f32>(v_r, v_g, v_b, 1.0f);
}
fn f_blend(cw_arg_a: vec4<f32>, cw_arg_b: vec4<f32>, cw_arg_t: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec4<f32> {
  var v_a: vec4<f32> = cw_arg_a;
  var v_b: vec4<f32> = cw_arg_b;
  var v_t: f32 = cw_arg_t;
  return (v_a + ((v_b - v_a) * vec4<f32>(f_sat(v_t, cw_thread, cw_block, cw_grid))));
}
fn f_ink(cw_arg_d: f32, cw_arg_aa: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_d: f32 = cw_arg_d;
  var v_aa: f32 = cw_arg_aa;
  return f_sat((0.5f - cw_divide_f32(v_d, v_aa)), cw_thread, cw_block, cw_grid);
}
fn f_rgba(cw_arg_c: vec4<f32>, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> u32 {
  var v_c: vec4<f32> = cw_arg_c;
  var v_r: u32 = u32((f_sat(v_c.x, cw_thread, cw_block, cw_grid) * 255.0f));
  var v_g: u32 = u32((f_sat(v_c.y, cw_thread, cw_block, cw_grid) * 255.0f));
  var v_b: u32 = u32((f_sat(v_c.z, cw_thread, cw_block, cw_grid) * 255.0f));
  return (((v_r | (v_g << u32(8i))) | (v_b << u32(16i))) | 4278190080u);
}
fn f_unrgba(cw_arg_c: u32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec4<f32> {
  var v_c: u32 = cw_arg_c;
  return vec4<f32>(cw_divide_f32(f32((v_c & 255u)), 255.0f), cw_divide_f32(f32(((v_c >> u32(8i)) & 255u)), 255.0f), cw_divide_f32(f32(((v_c >> u32(16i)) & 255u)), 255.0f), 1.0f);
}
fn f_paint(cw_arg_base: vec4<f32>, cw_arg_pigment: vec4<f32>, cw_arg_mask: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec4<f32> {
  var v_base: vec4<f32> = cw_arg_base;
  var v_pigment: vec4<f32> = cw_arg_pigment;
  var v_mask: f32 = cw_arg_mask;
  var v_a: f32 = (f_sat(v_mask, cw_thread, cw_block, cw_grid) * f_sat(v_pigment.w, cw_thread, cw_block, cw_grid));
  var v_outA: f32 = (v_a + (v_base.w * (1.0f - v_a)));
  if ((v_outA < 0.00001f)) {
    return vec4<f32>(0.0f, 0.0f, 0.0f, 0.0f);
  }
  var v_keep: f32 = (v_base.w * (1.0f - v_a));
  return vec4<f32>(cw_divide_f32(((v_pigment.x * v_a) + (v_base.x * v_keep)), v_outA), cw_divide_f32(((v_pigment.y * v_a) + (v_base.y * v_keep)), v_outA), cw_divide_f32(((v_pigment.z * v_a) + (v_base.z * v_keep)), v_outA), v_outA);
}
fn f_cw_buffer_helper_0(cw_arg_x: f32, cw_arg_y: f32, cw_buffer_arg_2: i32, cw_arg_b: i32, cw_arg_time: f32, cw_arg_aa: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec4<f32> {
  var cw_buffer_offset_2: i32 = cw_buffer_arg_2;
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_b: i32 = cw_arg_b;
  var v_time: f32 = cw_arg_time;
  var v_aa: f32 = cw_arg_aa;
  var v_type: i32 = i32(b_E[(cw_buffer_offset_2 + (v_b + 6i))]);
  var v_age: f32 = b_E[(cw_buffer_offset_2 + (v_b + 7i))];
  var v_elite: f32 = b_E[(cw_buffer_offset_2 + (v_b + 35i))];
  var cw_tmp_8: f32;
  if ((v_elite > 0.5f)) {
    cw_tmp_8 = 1.48f;
  } else {
    cw_tmp_8 = 1.0f;
  }
  var v_scale: f32 = cw_tmp_8;
  v_x = cw_divide_f32(v_x, v_scale);
  v_y = cw_divide_f32(v_y, v_scale);
  v_aa = cw_divide_f32(v_aa, v_scale);
  var cw_tmp_9: f32;
  if ((v_type == 1i)) {
    cw_tmp_9 = 15.0f;
  } else {
    cw_tmp_9 = 10.0f;
  }
  var v_walk: f32 = sin(((v_age * cw_tmp_9) + b_E[(cw_buffer_offset_2 + (v_b + 12i))]));
  let cw_argument_index_10 = (cw_buffer_offset_2 + (v_b + 2i));
  let cw_argument_index_11 = (cw_buffer_offset_2 + (v_b + 3i));
  var v_moving: f32 = f_sat(cw_divide_f32(f_len2(b_E[cw_argument_index_10], b_E[cw_argument_index_11], cw_thread, cw_block, cw_grid), 60.0f), cw_thread, cw_block, cw_grid);
  var v_bob: f32 = ((abs(v_walk) * v_moving) * 1.6f);
  var v_c: vec4<f32> = vec4<f32>(0.0f, 0.0f, 0.0f, 0.0f);
  if ((b_E[(cw_buffer_offset_2 + (v_b + 4i))] < 0.0f)) {
    var v_stain: f32 = (f_ink((f_len2(cw_divide_f32(v_x, 1.7f), cw_divide_f32(v_y, 0.8f), cw_thread, cw_block, cw_grid) - 15.0f), (v_aa * 2.0f), cw_thread, cw_block, cw_grid) * (0.5f + (0.2f * f_noise2((v_x * 0.3f), (v_y * 0.3f), cw_thread, cw_block, cw_grid))));
    v_c = vec4<f32>(0.13f, 0.034f, 0.029f, (v_stain * f_sat((1.0f - cw_divide_f32(b_E[(cw_buffer_offset_2 + (v_b + 18i))], 16.0f)), cw_thread, cw_block, cw_grid)));
    var v_bones: f32 = (f_ink((f_segment(v_x, v_y, (-9.0f), (-3.0f), 10.0f, 2.0f, cw_thread, cw_block, cw_grid) - 1.3f), v_aa, cw_thread, cw_block, cw_grid) * 0.3f);
    v_c = f_paint(v_c, f_color(0.35f, 0.32f, 0.25f, cw_thread, cw_block, cw_grid), v_bones, cw_thread, cw_block, cw_grid);
    if ((b_E[(cw_buffer_offset_2 + (v_b + 38i))] > 0.0f)) {
      var v_yy: f32 = ((v_y + 6.0f) + (sin(((v_time * 3.0f) + b_E[(cw_buffer_offset_2 + (v_b + 12i))])) * 2.0f));
      var v_gem: f32 = (((abs(v_x) * 0.85f) + (abs(v_yy) * 0.65f)) - 4.0f);
      var v_glow: f32 = (0.3f * exp(cw_divide_f32((-f_len2(v_x, v_yy, cw_thread, cw_block, cw_grid)), 10.0f)));
      v_c = f_paint(v_c, f_color(0.4f, 0.33f, 0.16f, cw_thread, cw_block, cw_grid), v_glow, cw_thread, cw_block, cw_grid);
      v_c = f_paint(v_c, f_color(0.87f, 0.74f, 0.42f, cw_thread, cw_block, cw_grid), f_ink(v_gem, v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_c = f_paint(v_c, f_color(1.0f, 0.95f, 0.74f, cw_thread, cw_block, cw_grid), f_ink((v_gem + 2.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    }
    return v_c;
  }
  if ((((abs(v_x) > 40.0f) || (v_y < (-52.0f))) || (v_y > 28.0f))) {
    return vec4<f32>(0.0f, 0.0f, 0.0f, 0.0f);
  }
  var v_yy: f32 = (v_y + v_bob);
  var v_shade: f32 = ((0.75f + (0.16f * f_noise2((v_x * 0.48f), (v_yy * 0.48f), cw_thread, cw_block, cw_grid))) + (0.12f * f_sat(cw_divide_f32((-v_x), 15.0f), cw_thread, cw_block, cw_grid)));
  if ((v_type == 1i)) {
    var v_fx: f32 = b_E[(cw_buffer_offset_2 + (v_b + 2i))];
    var v_fy: f32 = b_E[(cw_buffer_offset_2 + (v_b + 3i))];
    var v_fl: f32 = f_len2(v_fx, v_fy, cw_thread, cw_block, cw_grid);
    if ((v_fl < 8.0f)) {
      let cw_argument_index_12 = (cw_buffer_offset_2 + (v_b + 12i));
      v_fx = cos(b_E[cw_argument_index_12]);
      let cw_argument_index_13 = (cw_buffer_offset_2 + (v_b + 12i));
      v_fy = sin(b_E[cw_argument_index_13]);
    } else {
      v_fx = cw_divide_f32(v_fx, v_fl);
      v_fy = cw_divide_f32(v_fy, v_fl);
    }
    var v_rx: f32 = ((v_x * v_fx) + (v_yy * v_fy));
    var v_ry: f32 = (((-v_x) * v_fy) + (v_yy * v_fx));
    var v_body: f32 = (f_len2(cw_divide_f32(v_rx, 1.8f), v_ry, cw_thread, cw_block, cw_grid) - 8.0f);
    v_c = f_paint(v_c, f_color((0.24f * v_shade), (0.23f * v_shade), (0.21f * v_shade), cw_thread, cw_block, cw_grid), f_ink(v_body, v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    v_c = f_paint(v_c, f_color(0.36f, 0.34f, 0.29f, cw_thread, cw_block, cw_grid), f_ink((f_len2(cw_divide_f32((v_rx - 12.0f), 1.2f), v_ry, cw_thread, cw_block, cw_grid) - 6.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    {
      var v_k: i32 = 0i;
      loop {
        if (!(v_k < 4i)) { break; }
        var cw_tmp_14: f32;
        if (((v_k % 2i) == 0i)) {
          cw_tmp_14 = (-1.0f);
        } else {
          cw_tmp_14 = 1.0f;
        }
        var v_side: f32 = cw_tmp_14;
        var cw_tmp_15: f32;
        if ((v_k < 2i)) {
          cw_tmp_15 = (-9.0f);
        } else {
          cw_tmp_15 = 7.0f;
        }
        var v_leg: f32 = cw_tmp_15;
        var cw_tmp_16: f32;
        if (((v_k % 2i) == 0i)) {
          cw_tmp_16 = 1.0f;
        } else {
          cw_tmp_16 = (-1.0f);
        }
        var v_step: f32 = ((v_walk * cw_tmp_16) * 3.0f);
        v_c = f_paint(v_c, f_color(0.22f, 0.21f, 0.18f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_rx, v_ry, v_leg, (v_side * 5.0f), (v_leg + v_step), (v_side * 12.0f), cw_thread, cw_block, cw_grid) - 1.5f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
        continuing {
          v_k += i32(1);
        }
      }
    }
    v_c = f_paint(v_c, f_color(0.12f, 0.12f, 0.11f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_rx, v_ry, (-11.0f), 0.0f, (-23.0f), (sin((v_age * 9.0f)) * 5.0f), cw_thread, cw_block, cw_grid) - 2.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    v_c = f_paint(v_c, f_color(0.67f, 0.16f, 0.08f, cw_thread, cw_block, cw_grid), f_ink((f_len2((v_rx - 15.0f), (abs(v_ry) - 3.5f), cw_thread, cw_block, cw_grid) - 1.1f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    v_c = f_paint(v_c, f_color(0.59f, 0.54f, 0.43f, cw_thread, cw_block, cw_grid), f_ink(f_boxd((v_rx - 19.0f), v_ry, 3.0f, 2.0f, cw_thread, cw_block, cw_grid), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  } else {
    var cw_tmp_18: f32;
    if ((v_type == 3i)) {
      cw_tmp_18 = 17.0f;
    } else {
      var cw_tmp_17: f32;
      if ((v_type == 4i)) {
        cw_tmp_17 = 9.0f;
      } else {
        cw_tmp_17 = 11.0f;
      }
      cw_tmp_18 = cw_tmp_17;
    }
    var v_width: f32 = cw_tmp_18;
    var cw_tmp_19: f32;
    if ((v_type == 3i)) {
      cw_tmp_19 = (-34.0f);
    } else {
      cw_tmp_19 = (-29.0f);
    }
    var v_top: f32 = cw_tmp_19;
    var v_step: f32 = ((v_walk * v_moving) * 3.5f);
    v_c = f_paint(v_c, f_color(0.13f, 0.13f, 0.12f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_x, v_yy, (-5.0f), (-4.0f), (-7.0f), (3.0f + v_step), cw_thread, cw_block, cw_grid) - 3.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    v_c = f_paint(v_c, f_color(0.16f, 0.16f, 0.14f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_x, v_yy, 5.0f, (-4.0f), 7.0f, (3.0f - v_step), cw_thread, cw_block, cw_grid) - 3.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    var v_body: f32 = max((abs(v_x) - (v_width + ((v_yy + 18.0f) * 0.16f))), max(((v_top + 8.0f) - v_yy), (v_yy + 3.0f)));
    var v_cloth: vec4<f32> = f_color((0.27f * v_shade), (0.28f * v_shade), (0.23f * v_shade), cw_thread, cw_block, cw_grid);
    if ((v_type == 2i)) {
      v_cloth = f_color((0.33f * v_shade), (0.17f * v_shade), (0.16f * v_shade), cw_thread, cw_block, cw_grid);
    }
    if ((v_type == 3i)) {
      v_cloth = f_color((0.32f * v_shade), (0.28f * v_shade), (0.24f * v_shade), cw_thread, cw_block, cw_grid);
    }
    if ((v_type == 4i)) {
      v_cloth = f_color((0.2f * v_shade), (0.29f * v_shade), (0.3f * v_shade), cw_thread, cw_block, cw_grid);
    }
    v_c = f_paint(v_c, v_cloth, f_ink(v_body, v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    var v_seam: f32 = (f_ink((abs((v_x - (sin((v_yy * 0.19f)) * 2.0f))) - 0.6f), v_aa, cw_thread, cw_block, cw_grid) * f_ink((v_body + 1.0f), v_aa, cw_thread, cw_block, cw_grid));
    v_c = f_paint(v_c, f_color(0.095f, 0.1f, 0.087f, cw_thread, cw_block, cw_grid), v_seam, cw_thread, cw_block, cw_grid);
    var cw_tmp_20: f32;
    if ((b_E[(cw_buffer_offset_2 + (v_b + 8i))] == 4.0f)) {
      cw_tmp_20 = 8.0f;
    } else {
      cw_tmp_20 = 0.0f;
    }
    var v_swing: f32 = cw_tmp_20;
    v_c = f_paint(v_c, (v_cloth * vec4<f32>(0.85f)), f_ink((f_segment(v_x, v_yy, ((-v_width) + 2.0f), (-22.0f), (((-v_width) - 5.0f) - v_swing), ((-5.0f) + v_step), cw_thread, cw_block, cw_grid) - 3.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    v_c = f_paint(v_c, (v_cloth * vec4<f32>(1.2f)), f_ink((f_segment(v_x, v_yy, (v_width - 2.0f), (-22.0f), ((v_width + 4.0f) + v_swing), ((-7.0f) - v_step), cw_thread, cw_block, cw_grid) - 3.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    var v_head: f32 = (f_len2((v_x * 0.92f), (v_yy - (v_top + 2.0f)), cw_thread, cw_block, cw_grid) - 7.6f);
    v_c = f_paint(v_c, f_color((0.47f * v_shade), (0.45f * v_shade), (0.36f * v_shade), cw_thread, cw_block, cw_grid), f_ink(v_head, v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    if (((v_type == 2i) || (v_type == 4i))) {
      v_c = f_paint(v_c, (v_cloth * vec4<f32>(0.75f)), f_ink((v_head - 2.5f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_c = f_paint(v_c, f_color(0.042f, 0.049f, 0.047f, cw_thread, cw_block, cw_grid), f_ink((f_len2(v_x, (v_yy - (v_top + 3.0f)), cw_thread, cw_block, cw_grid) - 5.6f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    }
    v_c = f_paint(v_c, f_color(0.09f, 0.079f, 0.062f, cw_thread, cw_block, cw_grid), f_ink(f_boxd(v_x, (v_yy - (v_top + 5.0f)), 4.8f, 2.2f, cw_thread, cw_block, cw_grid), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    var v_eye: f32 = f_ink((f_len2((abs(v_x) - 2.9f), (v_yy - (v_top + 3.0f)), cw_thread, cw_block, cw_grid) - 0.95f), v_aa, cw_thread, cw_block, cw_grid);
    var cw_tmp_21: vec4<f32>;
    if ((v_type == 4i)) {
      cw_tmp_21 = f_color(0.46f, 0.8f, 0.72f, cw_thread, cw_block, cw_grid);
    } else {
      cw_tmp_21 = f_color(0.83f, 0.27f, 0.13f, cw_thread, cw_block, cw_grid);
    }
    v_c = f_paint(v_c, cw_tmp_21, v_eye, cw_thread, cw_block, cw_grid);
    if (((v_type == 0i) || (v_type == 3i))) {
      {
        var v_k: i32 = 0i;
        loop {
          if (!(v_k < 3i)) { break; }
          var v_rib: f32 = f_ink((f_segment(v_x, v_yy, ((-v_width) * 0.55f), ((-20.0f) + (f32(v_k) * 3.6f)), (v_width * 0.55f), ((-18.0f) + (f32(v_k) * 3.6f)), cw_thread, cw_block, cw_grid) - 0.8f), v_aa, cw_thread, cw_block, cw_grid);
          v_c = f_paint(v_c, f_color((0.42f * v_shade), (0.38f * v_shade), (0.29f * v_shade), cw_thread, cw_block, cw_grid), v_rib, cw_thread, cw_block, cw_grid);
          continuing {
            v_k += i32(1);
          }
        }
      }
    }
    if ((v_type == 2i)) {
      v_c = f_paint(v_c, f_color(0.44f, 0.37f, 0.23f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_x, v_yy, 18.0f, (-1.0f), 21.0f, (-36.0f), cw_thread, cw_block, cw_grid) - 1.3f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      var v_light: f32 = f_len2((v_x - 21.0f), (v_yy + 36.0f), cw_thread, cw_block, cw_grid);
      v_c = f_paint(v_c, f_color(0.71f, 0.43f, 0.2f, cw_thread, cw_block, cw_grid), (exp(cw_divide_f32((-v_light), 8.0f)) * 0.65f), cw_thread, cw_block, cw_grid);
      v_c = f_paint(v_c, f_color(0.97f, 0.74f, 0.39f, cw_thread, cw_block, cw_grid), f_ink((v_light - 2.5f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    }
    if ((v_type == 3i)) {
      v_c = f_paint(v_c, f_color(0.18f, 0.2f, 0.19f, cw_thread, cw_block, cw_grid), f_ink((f_len2(((abs(v_x) - 14.0f) * 0.8f), (v_yy + 24.0f), cw_thread, cw_block, cw_grid) - 6.5f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_c = f_paint(v_c, f_color(0.52f, 0.46f, 0.32f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_x, v_yy, (-7.0f), (-29.0f), (-11.0f), (-43.0f), cw_thread, cw_block, cw_grid) - 1.6f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_c = f_paint(v_c, f_color(0.52f, 0.46f, 0.32f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_x, v_yy, 7.0f, (-29.0f), 11.0f, (-43.0f), cw_thread, cw_block, cw_grid) - 1.6f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    }
    if ((v_type == 4i)) {
      v_c = f_paint(v_c, f_color(0.6f, 0.71f, 0.66f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_x, v_yy, (-14.0f), (-12.0f), (-22.0f), 6.0f, cw_thread, cw_block, cw_grid) - 1.1f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_c = f_paint(v_c, f_color(0.6f, 0.71f, 0.66f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_x, v_yy, 14.0f, (-12.0f), 22.0f, 6.0f, cw_thread, cw_block, cw_grid) - 1.1f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    }
  }
  if ((b_E[(cw_buffer_offset_2 + (v_b + 17i))] > 0.0f)) {
    var v_flash: f32 = (f_sat(cw_divide_f32(b_E[(cw_buffer_offset_2 + (v_b + 17i))], 0.13f), cw_thread, cw_block, cw_grid) * 0.7f);
    v_c.x = f_mixf(v_c.x, 0.96f, v_flash, cw_thread, cw_block, cw_grid);
    v_c.y = f_mixf(v_c.y, 0.86f, v_flash, cw_thread, cw_block, cw_grid);
    v_c.z = f_mixf(v_c.z, 0.64f, v_flash, cw_thread, cw_block, cw_grid);
  }
  if ((b_E[(cw_buffer_offset_2 + (v_b + 4i))] < (b_E[(cw_buffer_offset_2 + (v_b + 5i))] * 0.99f))) {
    var v_hp: f32 = f_sat(cw_divide_f32(b_E[(cw_buffer_offset_2 + (v_b + 4i))], b_E[(cw_buffer_offset_2 + (v_b + 5i))]), cw_thread, cw_block, cw_grid);
    var v_bar: f32 = f_ink(f_boxd(v_x, (v_y - 11.0f), 13.0f, 1.0f, cw_thread, cw_block, cw_grid), v_aa, cw_thread, cw_block, cw_grid);
    v_c = f_paint(v_c, f_color(0.13f, 0.08f, 0.07f, cw_thread, cw_block, cw_grid), v_bar, cw_thread, cw_block, cw_grid);
    if ((v_x < ((-13.0f) + (26.0f * v_hp)))) {
      v_c = f_paint(v_c, f_color(0.63f, 0.2f, 0.13f, cw_thread, cw_block, cw_grid), v_bar, cw_thread, cw_block, cw_grid);
    }
  }
  return v_c;
}
fn f_cw_buffer_helper_1(cw_arg_x: f32, cw_arg_y: f32, cw_buffer_arg_2: i32, cw_arg_aa: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec4<f32> {
  var cw_buffer_offset_2: i32 = cw_buffer_arg_2;
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_aa: f32 = cw_arg_aa;
  if ((((abs(v_x) > 58.0f) || (v_y < (-62.0f))) || (v_y > 38.0f))) {
    return vec4<f32>(0.0f, 0.0f, 0.0f, 0.0f);
  }
  var v_time: f32 = b_S[(cw_buffer_offset_2 + 6i)];
  let cw_argument_index_22 = (cw_buffer_offset_2 + 2i);
  let cw_argument_index_23 = (cw_buffer_offset_2 + 3i);
  var v_walk: f32 = (sin((v_time * 13.0f)) * f_sat(cw_divide_f32(f_len2(b_S[cw_argument_index_22], b_S[cw_argument_index_23], cw_thread, cw_block, cw_grid), 130.0f), cw_thread, cw_block, cw_grid));
  var v_yy: f32 = (v_y + (abs(v_walk) * 1.0f));
  var v_c: vec4<f32> = vec4<f32>(0.0f, 0.0f, 0.0f, 0.0f);
  v_c = f_paint(v_c, f_color(0.16f, 0.17f, 0.16f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_x, v_yy, (-5.0f), (-5.0f), (-7.0f), (4.0f + (v_walk * 3.0f)), cw_thread, cw_block, cw_grid) - 3.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_c = f_paint(v_c, f_color(0.2f, 0.2f, 0.18f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_x, v_yy, 5.0f, (-5.0f), 7.0f, (4.0f - (v_walk * 3.0f)), cw_thread, cw_block, cw_grid) - 3.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  var v_cloak: f32 = max((abs((v_x + (sin(((v_yy * 0.2f) + (v_time * 4.0f))) * 1.3f))) - (10.5f + ((v_yy + 21.0f) * 0.16f))), max(((-28.0f) - v_yy), (v_yy + 2.0f)));
  v_c = f_paint(v_c, f_color(0.15f, 0.19f, 0.2f, cw_thread, cw_block, cw_grid), f_ink(v_cloak, v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_c = f_paint(v_c, f_color(0.26f, 0.29f, 0.27f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_x, v_yy, (-8.0f), (-21.0f), (-10.0f), (-3.0f), cw_thread, cw_block, cw_grid) - 1.4f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_c = f_paint(v_c, f_color(0.11f, 0.13f, 0.13f, cw_thread, cw_block, cw_grid), f_ink(f_boxd(v_x, (v_yy + 14.0f), 6.0f, 9.0f, cw_thread, cw_block, cw_grid), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_c = f_paint(v_c, f_color(0.58f, 0.54f, 0.4f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_x, v_yy, (-8.0f), (-18.0f), 5.0f, (-5.0f), cw_thread, cw_block, cw_grid) - 1.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_c = f_paint(v_c, f_color(0.45f, 0.48f, 0.43f, cw_thread, cw_block, cw_grid), f_ink(f_boxd((v_x + 1.0f), (v_yy + 19.0f), 2.3f, 3.5f, cw_thread, cw_block, cw_grid), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  var v_hood: f32 = (f_len2(v_x, (v_yy + 30.0f), cw_thread, cw_block, cw_grid) - 9.2f);
  v_c = f_paint(v_c, f_color(0.28f, 0.32f, 0.3f, cw_thread, cw_block, cw_grid), f_ink(v_hood, v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_c = f_paint(v_c, f_color(0.049f, 0.065f, 0.069f, cw_thread, cw_block, cw_grid), f_ink((f_len2((v_x - 1.0f), (v_yy + 28.0f), cw_thread, cw_block, cw_grid) - 6.4f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_c = f_paint(v_c, f_color(0.74f, 0.71f, 0.6f, cw_thread, cw_block, cw_grid), f_ink(f_boxd((v_x - 1.0f), (v_yy + 27.0f), 4.0f, 3.5f, cw_thread, cw_block, cw_grid), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_c = f_paint(v_c, f_color(0.12f, 0.16f, 0.16f, cw_thread, cw_block, cw_grid), f_ink(f_boxd((v_x - 1.0f), (v_yy + 28.0f), 4.4f, 0.9f, cw_thread, cw_block, cw_grid), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_c = f_paint(v_c, f_color(0.47f, 0.13f, 0.1f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_x, v_yy, (-6.0f), (-21.0f), 8.0f, (-22.0f), cw_thread, cw_block, cw_grid) - 2.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_c = f_paint(v_c, f_color(0.43f, 0.12f, 0.085f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_x, v_yy, 7.0f, (-22.0f), (14.0f + (sin((v_time * 5.0f)) * 2.0f)), (-7.0f), cw_thread, cw_block, cw_grid) - 1.8f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  var v_ax: f32 = b_S[(cw_buffer_offset_2 + 23i)];
  var v_ay: f32 = b_S[(cw_buffer_offset_2 + 24i)];
  var v_sx: f32 = (v_ax * 9.0f);
  var v_sy: f32 = ((v_ay * 9.0f) - 12.0f);
  v_c = f_paint(v_c, f_color(0.31f, 0.33f, 0.3f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_x, v_yy, 6.0f, (-15.0f), v_sx, v_sy, cw_thread, cw_block, cw_grid) - 3.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_c = f_paint(v_c, f_color(0.66f, 0.64f, 0.53f, cw_thread, cw_block, cw_grid), f_ink((f_segment(v_x, v_yy, v_sx, v_sy, (v_sx + (v_ax * 17.0f)), (v_sy + (v_ay * 17.0f)), cw_thread, cw_block, cw_grid) - 1.8f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  if ((b_S[(cw_buffer_offset_2 + 15i)] > (cw_divide_f32(0.28f, b_S[(cw_buffer_offset_2 + 33i)]) - 0.055f))) {
    var v_muzzle: f32 = f_len2(((v_x - v_sx) - (v_ax * 22.0f)), ((v_yy - v_sy) - (v_ay * 22.0f)), cw_thread, cw_block, cw_grid);
    v_c = f_paint(v_c, f_color(0.81f, 0.46f, 0.2f, cw_thread, cw_block, cw_grid), (exp(cw_divide_f32((-v_muzzle), 10.0f)) * 0.5f), cw_thread, cw_block, cw_grid);
    v_c = f_paint(v_c, f_color(1.0f, 0.92f, 0.59f, cw_thread, cw_block, cw_grid), f_ink((v_muzzle - 3.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  }
  if (((b_S[(cw_buffer_offset_2 + 38i)] > 0.0f) && (f_frac((b_S[(cw_buffer_offset_2 + 38i)] * 16.0f), cw_thread, cw_block, cw_grid) < 0.5f))) {
    v_c.x = f_mixf(v_c.x, 0.8f, 0.35f, cw_thread, cw_block, cw_grid);
    v_c.y = (v_c.y * 0.7f);
  }
  return v_c;
}

fn cw_pow_f32(base: f32, exponent: f32) -> f32 {
  if(exponent >= -64.0f && exponent <= 64.0f && exponent == trunc(exponent)) {
    var count=u32(abs(exponent));
    var value=cw_d_from_f32(base);var product=cw_d_from_u32(1u);
    loop {
      if(count == 0u) { break; }
      if((count & 1u) != 0u) { product=cw_d_mul(product,value); }
      count >>= 1u;
      if(count != 0u) { value=cw_d_mul(value,value); }
    }
    if(exponent < 0.0f) { product=cw_d_div(cw_d_from_u32(1u),product); }
    return cw_d_to_f32(product);
  }
  return pow(base,exponent);
}

@compute @workgroup_size(8, 8, 1)
fn main(
  @builtin(local_invocation_id) cw_thread: vec3<u32>,
  @builtin(workgroup_id) cw_block: vec3<u32>,
  @builtin(num_workgroups) cw_grid: vec3<u32>
) {
  var v_ix: i32 = i32(((cw_block.x * cw_block_size.x) + cw_thread.x));
  var v_iy: i32 = i32(((cw_block.y * cw_block_size.y) + cw_thread.y));
  if (((v_ix >= cw_params.p_width) || (v_iy >= cw_params.p_height))) {
    return;
  }
  var v_zoom: f32 = cw_divide_f32(f32(cw_params.p_height), 700.0f);
  var v_aa: f32 = cw_divide_f32(1.1f, v_zoom);
  var v_time: f32 = b_S[46i];
  var v_gameTime: f32 = b_S[6i];
  var v_wx: f32 = (cw_divide_f32((f32(v_ix) - (f32(cw_params.p_width) * 0.5f)), v_zoom) + b_S[25i]);
  var v_wy: f32 = (cw_divide_f32((f32(v_iy) - (f32(cw_params.p_height) * 0.5f)), v_zoom) + b_S[26i]);
  let cw_argument_index_0 = ((v_iy * cw_params.p_width) + v_ix);
  var v_c: vec4<f32> = f_unrgba(b_Pixels[cw_argument_index_0], cw_thread, cw_block, cw_grid);
  var v_depth: f32 = (-100000.0f);
  var v_front: vec4<f32> = vec4<f32>(0.0f, 0.0f, 0.0f, 0.0f);
  var v_gx: f32 = floor(cw_divide_f32((v_wx + 96.0f), 192.0f));
  var v_gy: f32 = floor(cw_divide_f32((v_wy + 96.0f), 192.0f));
  var v_ox: f32 = ((v_gx * 192.0f) + ((f_h2(v_gx, v_gy, cw_thread, cw_block, cw_grid) - 0.5f) * 60.0f));
  var v_oy: f32 = ((v_gy * 192.0f) + ((f_h2(v_gy, (v_gx + 31.0f), cw_thread, cw_block, cw_grid) - 0.5f) * 50.0f));
  if (((f_len2(v_ox, v_oy, cw_thread, cw_block, cw_grid) > 235.0f) && (f_h2((v_gx + 82.0f), v_gy, cw_thread, cw_block, cw_grid) >= 0.35f))) {
    var v_x: f32 = (v_wx - v_ox);
    var v_y: f32 = (v_wy - v_oy);
    var v_shadow: f32 = (exp(cw_divide_f32((-f_len2(cw_divide_f32((v_x - 9.0f), 1.7f), cw_divide_f32((v_y - 9.0f), 0.6f), cw_thread, cw_block, cw_grid)), 14.0f)) * 0.55f);
    v_c = (v_c * vec4<f32>((1.0f - v_shadow)));
    var v_kind: f32 = f_h2((v_gx + 83.0f), (v_gy + 49.0f), cw_thread, cw_block, cw_grid);
    var v_d: f32 = min(f_boxd(v_x, (v_y + 16.0f), 14.0f, 18.0f, cw_thread, cw_block, cw_grid), (f_len2(v_x, (v_y + 34.0f), cw_thread, cw_block, cw_grid) - 14.0f));
    if ((v_kind > 0.64f)) {
      v_d = min(f_boxd(v_x, (v_y + 25.0f), 5.5f, 28.0f, cw_thread, cw_block, cw_grid), f_boxd(v_x, (v_y + 36.0f), 18.0f, 5.0f, cw_thread, cw_block, cw_grid));
    } else {
      if ((v_kind > 0.36f)) {
        v_d = f_boxd(v_x, (v_y + 23.0f), 10.0f, 25.0f, cw_thread, cw_block, cw_grid);
        v_d = max(v_d, ((-((v_x + v_y) + 47.0f)) * 0.7f));
      }
    }
    var v_prop: vec4<f32> = f_color(0.28f, 0.3f, 0.27f, cw_thread, cw_block, cw_grid);
    var v_pat: f32 = f_noise2((v_wx * 0.22f), (v_wy * 0.22f), cw_thread, cw_block, cw_grid);
    v_prop = (v_prop * vec4<f32>(((0.7f + (v_pat * 0.32f)) + (f_sat(cw_divide_f32((-v_x), 18.0f), cw_thread, cw_block, cw_grid) * 0.16f))));
    var v_border: f32 = f_ink((abs((v_d + 2.0f)) - 0.7f), v_aa, cw_thread, cw_block, cw_grid);
    v_prop = f_blend(v_prop, f_color(0.4f, 0.41f, 0.34f, cw_thread, cw_block, cw_grid), (v_border * 0.6f), cw_thread, cw_block, cw_grid);
    var v_cut: f32 = min(f_segment(v_x, v_y, 0.0f, (-34.0f), 0.0f, (-13.0f), cw_thread, cw_block, cw_grid), f_segment(v_x, v_y, (-6.0f), (-27.0f), 6.0f, (-27.0f), cw_thread, cw_block, cw_grid));
    v_prop = f_blend(v_prop, f_color(0.11f, 0.13f, 0.12f, cw_thread, cw_block, cw_grid), f_ink((v_cut - 1.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    var v_base: f32 = f_boxd(v_x, v_y, 19.0f, 5.0f, cw_thread, cw_block, cw_grid);
    if ((v_base < v_d)) {
      v_d = v_base;
      v_prop = f_color(0.2f, 0.23f, 0.21f, cw_thread, cw_block, cw_grid);
    }
    var v_stoneSprite: vec4<f32> = vec4<f32>(v_prop.x, v_prop.y, v_prop.z, f_ink(v_d, v_aa, cw_thread, cw_block, cw_grid));
    if ((v_stoneSprite.w > 0.004f)) {
      if (((v_oy + 8.0f) >= v_depth)) {
        v_c = f_blend(v_c, f_color(v_front.x, v_front.y, v_front.z, cw_thread, cw_block, cw_grid), v_front.w, cw_thread, cw_block, cw_grid);
        v_front = v_stoneSprite;
        v_depth = (v_oy + 8.0f);
      } else {
        v_c = f_blend(v_c, f_color(v_stoneSprite.x, v_stoneSprite.y, v_stoneSprite.z, cw_thread, cw_block, cw_grid), v_stoneSprite.w, cw_thread, cw_block, cw_grid);
      }
    }
  }
  var v_tile: i32 = ((((v_iy / 32i) * (((cw_params.p_width + 32i) - 1i) / 32i)) + (v_ix / 32i)) * 128i);
  var v_count: i32 = b_Tiles[v_tile];
  if (((v_count < 0i) || (v_count > (128i - 1i)))) {
    v_count = 0i;
  }
  var v_shade: f32 = 0.0f;
  {
    var v_j: i32 = 0i;
    loop {
      if (!(v_j < v_count)) { break; }
      if ((b_Tiles[((v_tile + 1i) + v_j)] < 1000i)) {
        var v_b: i32 = (b_Tiles[((v_tile + 1i) + v_j)] * 48i);
        var v_x: f32 = (v_wx - b_E[v_b]);
        var v_y: f32 = (v_wy - b_E[(v_b + 1i)]);
        if ((b_E[(v_b + 4i)] < 0.0f)) {
          var v_sprite: vec4<f32> = f_cw_buffer_helper_0(v_x, v_y, 0i, v_b, v_gameTime, v_aa, cw_thread, cw_block, cw_grid);
          v_c = f_blend(v_c, f_color(v_sprite.x, v_sprite.y, v_sprite.z, cw_thread, cw_block, cw_grid), v_sprite.w, cw_thread, cw_block, cw_grid);
        } else {
          v_shade = max(v_shade, (exp(cw_divide_f32((-f_len2(cw_divide_f32(v_x, 1.5f), cw_divide_f32(v_y, 0.55f), cw_thread, cw_block, cw_grid)), 12.0f)) * 0.28f));
          if ((b_E[(v_b + 8i)] == 4.0f)) {
            var cw_tmp_1: f32;
            if ((b_E[(v_b + 6i)] == 3.0f)) {
              cw_tmp_1 = 36.0f;
            } else {
              cw_tmp_1 = 27.0f;
            }
            var v_r: f32 = cw_tmp_1;
            var v_ring: f32 = (abs((f_len2(v_x, (v_y * 1.2f), cw_thread, cw_block, cw_grid) - v_r)) - 1.2f);
            v_c = f_blend(v_c, f_color(0.73f, 0.25f, 0.12f, cw_thread, cw_block, cw_grid), (f_ink(v_ring, v_aa, cw_thread, cw_block, cw_grid) * 0.55f), cw_thread, cw_block, cw_grid);
          }
          var v_sprite: vec4<f32> = f_cw_buffer_helper_0(v_x, v_y, 0i, v_b, v_gameTime, v_aa, cw_thread, cw_block, cw_grid);
          if ((v_sprite.w > 0.004f)) {
            if ((b_E[(v_b + 1i)] >= v_depth)) {
              v_c = f_blend(v_c, f_color(v_front.x, v_front.y, v_front.z, cw_thread, cw_block, cw_grid), v_front.w, cw_thread, cw_block, cw_grid);
              v_front = v_sprite;
              v_depth = b_E[(v_b + 1i)];
            } else {
              v_c = f_blend(v_c, f_color(v_sprite.x, v_sprite.y, v_sprite.z, cw_thread, cw_block, cw_grid), v_sprite.w, cw_thread, cw_block, cw_grid);
            }
          }
        }
      }
      continuing {
        v_j += i32(1);
      }
    }
  }
  v_c = (v_c * vec4<f32>((1.0f - v_shade)));
  var v_pshadow: f32 = (exp(cw_divide_f32((-f_len2(cw_divide_f32((v_wx - b_S[0i]), 1.45f), cw_divide_f32((v_wy - b_S[1i]), 0.55f), cw_thread, cw_block, cw_grid)), 12.0f)) * 0.38f);
  v_c = (v_c * vec4<f32>((1.0f - v_pshadow)));
  var v_player: vec4<f32> = f_cw_buffer_helper_1((v_wx - b_S[0i]), (v_wy - b_S[1i]), 0i, v_aa, cw_thread, cw_block, cw_grid);
  if ((v_player.w > 0.004f)) {
    if ((b_S[1i] >= v_depth)) {
      v_c = f_blend(v_c, f_color(v_front.x, v_front.y, v_front.z, cw_thread, cw_block, cw_grid), v_front.w, cw_thread, cw_block, cw_grid);
      v_front = v_player;
      v_depth = b_S[1i];
    } else {
      v_c = f_blend(v_c, f_color(v_player.x, v_player.y, v_player.z, cw_thread, cw_block, cw_grid), v_player.w, cw_thread, cw_block, cw_grid);
    }
  }
  {
    var v_k: i32 = 0i;
    loop {
      if (!(v_k < 4i)) { break; }
      var cw_tmp_2: f32;
      if (((v_k % 2i) == 0i)) {
        cw_tmp_2 = (-214.0f);
      } else {
        cw_tmp_2 = 214.0f;
      }
      var v_fx: f32 = cw_tmp_2;
      var cw_tmp_3: f32;
      if ((v_k < 2i)) {
        cw_tmp_3 = (-144.0f);
      } else {
        cw_tmp_3 = 144.0f;
      }
      var v_fy: f32 = cw_tmp_3;
      var v_x: f32 = (v_wx - v_fx);
      var v_y: f32 = (v_wy - v_fy);
      if ((((abs(v_x) < 23.0f) && (abs(v_y) < 55.0f)) && ((v_fy + 10.0f) < v_depth))) {
        v_c = f_blend(v_c, f_color(0.23f, 0.22f, 0.17f, cw_thread, cw_block, cw_grid), f_ink(f_boxd(v_x, (v_y + 9.0f), 3.0f, 11.0f, cw_thread, cw_block, cw_grid), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
        v_c = f_blend(v_c, f_color(0.38f, 0.31f, 0.2f, cw_thread, cw_block, cw_grid), f_ink(f_boxd(v_x, (v_y + 22.0f), 8.0f, 3.0f, cw_thread, cw_block, cw_grid), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
        var v_fire: f32 = (f_len2(cw_divide_f32((v_x - (sin(((v_time * 8.0f) + (v_y * 0.25f))) * 1.2f)), 0.65f), ((v_y + 31.0f) * 0.8f), cw_thread, cw_block, cw_grid) - 7.0f);
        v_c = f_blend(v_c, f_color(0.94f, 0.46f, 0.13f, cw_thread, cw_block, cw_grid), f_ink(v_fire, v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
        v_c = f_blend(v_c, f_color(1.0f, 0.86f, 0.46f, cw_thread, cw_block, cw_grid), f_ink((v_fire + 3.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      }
      continuing {
        v_k += i32(1);
      }
    }
  }
  v_c = f_blend(v_c, f_color(v_front.x, v_front.y, v_front.z, cw_thread, cw_block, cw_grid), v_front.w, cw_thread, cw_block, cw_grid);
  {
    var v_k: i32 = 0i;
    loop {
      if (!(v_k < 4i)) { break; }
      var cw_tmp_4: f32;
      if (((v_k % 2i) == 0i)) {
        cw_tmp_4 = (-214.0f);
      } else {
        cw_tmp_4 = 214.0f;
      }
      var v_fx: f32 = cw_tmp_4;
      var cw_tmp_5: f32;
      if ((v_k < 2i)) {
        cw_tmp_5 = (-144.0f);
      } else {
        cw_tmp_5 = 144.0f;
      }
      var v_fy: f32 = cw_tmp_5;
      var v_x: f32 = (v_wx - v_fx);
      var v_y: f32 = (v_wy - v_fy);
      if ((((abs(v_x) < 23.0f) && (abs(v_y) < 55.0f)) && ((v_fy + 10.0f) >= v_depth))) {
        v_c = f_blend(v_c, f_color(0.23f, 0.22f, 0.17f, cw_thread, cw_block, cw_grid), f_ink(f_boxd(v_x, (v_y + 9.0f), 3.0f, 11.0f, cw_thread, cw_block, cw_grid), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
        v_c = f_blend(v_c, f_color(0.38f, 0.31f, 0.2f, cw_thread, cw_block, cw_grid), f_ink(f_boxd(v_x, (v_y + 22.0f), 8.0f, 3.0f, cw_thread, cw_block, cw_grid), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
        var v_fire: f32 = (f_len2(cw_divide_f32((v_x - (sin(((v_time * 8.0f) + (v_y * 0.25f))) * 1.2f)), 0.65f), ((v_y + 31.0f) * 0.8f), cw_thread, cw_block, cw_grid) - 7.0f);
        v_c = f_blend(v_c, f_color(0.94f, 0.46f, 0.13f, cw_thread, cw_block, cw_grid), f_ink(v_fire, v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
        v_c = f_blend(v_c, f_color(1.0f, 0.86f, 0.46f, cw_thread, cw_block, cw_grid), f_ink((v_fire + 3.0f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      }
      continuing {
        v_k += i32(1);
      }
    }
  }
  {
    var v_j: i32 = 0i;
    loop {
      if (!(v_j < v_count)) { break; }
      var v_id: i32 = b_Tiles[((v_tile + 1i) + v_j)];
      if (((v_id >= 1000i) && (v_id < 2000i))) {
        var v_b: i32 = ((v_id - 1000i) * 10i);
        let cw_argument_index_6 = v_b;
        let cw_argument_index_7 = (v_b + 1i);
        var v_d: f32 = f_segment(v_wx, v_wy, b_P[cw_argument_index_6], b_P[cw_argument_index_7], (b_P[v_b] - (b_P[(v_b + 4i)] * 0.024f)), (b_P[(v_b + 1i)] - (b_P[(v_b + 5i)] * 0.024f)), cw_thread, cw_block, cw_grid);
        var v_a: f32 = exp(cw_divide_f32((-v_d), 2.0f));
        v_c.x = (v_c.x + (v_a * 0.9f));
        v_c.y = (v_c.y + (v_a * 0.72f));
        v_c.z = (v_c.z + (v_a * 0.38f));
      }
      if ((v_id >= 2000i)) {
        var v_b: i32 = ((v_id - 2000i) * 48i);
        var v_d: f32 = f_len2((v_wx - b_E[(v_b + 29i)]), (v_wy - b_E[(v_b + 30i)]), cw_thread, cw_block, cw_grid);
        var v_a: f32 = exp(cw_divide_f32((-v_d), 4.0f));
        v_c.x = (v_c.x + (v_a * 0.8f));
        v_c.y = (v_c.y + (v_a * 0.29f));
        v_c.z = (v_c.z + (v_a * 0.1f));
      }
      continuing {
        v_j += i32(1);
      }
    }
  }
  {
    var v_k: i32 = 0i;
    loop {
      if (!(v_k < 5i)) { break; }
      if ((f32(v_k) < b_S[37i])) {
        var v_a: f32 = ((v_gameTime * 2.2f) + cw_divide_f32(((f32(v_k) * 3.14159265359f) * 2.0f), b_S[37i]));
        var v_dx: f32 = ((v_wx - b_S[0i]) - (cos(v_a) * 78.0f));
        var v_dy: f32 = ((v_wy - b_S[1i]) - (sin(v_a) * 78.0f));
        var v_knife: f32 = f_segment(v_dx, v_dy, ((-cos(v_a)) * 9.0f), ((-sin(v_a)) * 9.0f), (cos(v_a) * 9.0f), (sin(v_a) * 9.0f), cw_thread, cw_block, cw_grid);
        v_c = f_blend(v_c, f_color(0.81f, 0.83f, 0.72f, cw_thread, cw_block, cw_grid), f_ink((v_knife - 1.2f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      }
      continuing {
        v_k += i32(1);
      }
    }
  }
  var v_mist: f32 = f_noise2(((v_wx * 0.006f) + (v_time * 0.025f)), ((v_wy * 0.008f) - (v_time * 0.012f)), cw_thread, cw_block, cw_grid);
  var v_fog: f32 = (f_smooth01(0.46f, 0.91f, v_mist, cw_thread, cw_block, cw_grid) * 0.13f);
  v_c = f_blend(v_c, f_color(0.34f, 0.38f, 0.37f, cw_thread, cw_block, cw_grid), v_fog, cw_thread, cw_block, cw_grid);
  var v_rainX: f32 = ((v_wx * 0.13f) - (v_wy * 0.035f));
  var v_rainY: f32 = ((v_wy * 0.04f) - (v_time * 16.0f));
  var v_cell: f32 = f_h2(floor(v_rainX), floor(v_rainY), cw_thread, cw_block, cw_grid);
  var v_rain: f32 = ((f_ink((abs((f_frac(v_rainX, cw_thread, cw_block, cw_grid) - 0.5f)) - 0.018f), 0.028f, cw_thread, cw_block, cw_grid) * cw_pow_f32((1.0f - f_frac(v_rainY, cw_thread, cw_block, cw_grid)), 1.65f)) * 0.14f);
  if ((v_cell > 0.78f)) {
    v_c = (v_c + f_color((v_rain * 0.85f), v_rain, v_rain, cw_thread, cw_block, cw_grid));
  }
  var v_nx: f32 = ((cw_divide_f32(f32(v_ix), f32(cw_params.p_width)) - 0.5f) * 2.0f);
  var v_ny: f32 = ((cw_divide_f32(f32(v_iy), f32(cw_params.p_height)) - 0.5f) * 2.0f);
  var v_vignette: f32 = (1.0f - (0.25f * cw_pow_f32(f_sat((((v_nx * v_nx) + (v_ny * v_ny)) * 0.48f), cw_thread, cw_block, cw_grid), 1.3f)));
  v_c = (v_c * vec4<f32>(v_vignette));
  var v_grain: f32 = ((f_h2((f32(v_ix) + floor((v_time * 12.0f))), f32(v_iy), cw_thread, cw_block, cw_grid) - 0.5f) * 0.013f);
  v_c.x = (v_c.x + v_grain);
  v_c.y = (v_c.y + v_grain);
  v_c.z = (v_c.z + v_grain);
  if (((b_S[4i] < 35.0f) && (b_S[8i] == 1.0f))) {
    var v_danger: f32 = ((1.0f - cw_divide_f32(b_S[4i], 35.0f)) * f_sat((((v_nx * v_nx) + (v_ny * v_ny)) * 0.45f), cw_thread, cw_block, cw_grid));
    v_c = f_blend(v_c, f_color(0.3f, 0.038f, 0.027f, cw_thread, cw_block, cw_grid), (v_danger * 0.45f), cw_thread, cw_block, cw_grid);
  }
  b_Pixels[((v_iy * cw_params.p_width) + v_ix)] = f_rgba(v_c, cw_thread, cw_block, cw_grid);
}
