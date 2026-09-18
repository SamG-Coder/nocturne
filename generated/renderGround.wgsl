// CUDA WebShader 0.1.0. Generated from kernel renderGround.
@group(0) @binding(0) var<storage, read> b_S: array<f32>;
@group(0) @binding(1) var<storage, read_write> b_Pixels: array<u32>;
struct CWParams {
  p_width: i32,
  p_height: i32,
  cw_pad_8: u32,
  cw_pad_12: u32,
}
@group(0) @binding(2) var<uniform> cw_params: CWParams;
const cw_block_size: vec3<u32> = vec3<u32>(8u, 8u, 1u);

fn cw_divide_f32(a: f32, b: f32) -> f32 { let q = a / b; if ((bitcast<u32>(q) & 0x7f800000u) == 0x7f800000u || (bitcast<u32>(q) & 0x7fffffffu) == 0u || (bitcast<u32>(b) & 0x7f800000u) == 0x7f800000u) { return q; } let residual = fma(-q, b, a); return q + residual / b; }
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
  var v_wx: f32 = (cw_divide_f32((f32(v_ix) - (f32(cw_params.p_width) * 0.5f)), v_zoom) + b_S[25i]);
  var v_wy: f32 = (cw_divide_f32((f32(v_iy) - (f32(cw_params.p_height) * 0.5f)), v_zoom) + b_S[26i]);
  var v_pd: f32 = f_len2((v_wx - b_S[0i]), (v_wy - b_S[1i]), cw_thread, cw_block, cw_grid);
  var v_radial: f32 = f_len2(v_wx, v_wy, cw_thread, cw_block, cw_grid);
  var v_ground: f32 = f_noise2((v_wx * 0.018f), (v_wy * 0.018f), cw_thread, cw_block, cw_grid);
  var v_detail: f32 = f_noise2((v_wx * 0.23f), (v_wy * 0.23f), cw_thread, cw_block, cw_grid);
  var v_c: vec4<f32> = f_color((0.071f + (v_ground * 0.035f)), (0.091f + (v_ground * 0.041f)), (0.092f + (v_ground * 0.038f)), cw_thread, cw_block, cw_grid);
  var v_row: f32 = floor(cw_divide_f32(v_wy, 33.0f));
  var v_tx: f32 = f_frac(cw_divide_f32((v_wx + ((v_row - (floor(cw_divide_f32(v_row, 2.0f)) * 2.0f)) * 28.0f)), 57.0f), cw_thread, cw_block, cw_grid);
  var v_ty: f32 = f_frac(cw_divide_f32(v_wy, 33.0f), cw_thread, cw_block, cw_grid);
  var v_joint: f32 = min((min(v_tx, (1.0f - v_tx)) * 57.0f), (min(v_ty, (1.0f - v_ty)) * 33.0f));
  var v_stoneNoise: f32 = f_h2(floor(cw_divide_f32((v_wx + ((v_row - (floor(cw_divide_f32(v_row, 2.0f)) * 2.0f)) * 28.0f)), 57.0f)), v_row, cw_thread, cw_block, cw_grid);
  var v_paving: vec4<f32> = f_color((0.13f + (v_stoneNoise * 0.028f)), (0.151f + (v_stoneNoise * 0.033f)), (0.149f + (v_stoneNoise * 0.035f)), cw_thread, cw_block, cw_grid);
  v_paving = (v_paving * vec4<f32>((0.65f + (v_detail * 0.43f))));
  v_paving = f_blend(f_color(0.042f, 0.052f, 0.052f, cw_thread, cw_block, cw_grid), v_paving, f_smooth01(0.0f, 1.4f, v_joint, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  var v_stone: f32 = 1.0f;
  if ((v_radial > 230.0f)) {
    var v_broken: f32 = f_smooth01(0.9f, 0.97f, v_stoneNoise, cw_thread, cw_block, cw_grid);
    var v_mud: f32 = f_smooth01(0.88f, 0.97f, f_noise2(((v_wx * 0.05f) + 3.1f), (v_wy * 0.05f), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    v_stone = (1.0f - max(v_broken, (v_mud * 0.35f)));
  }
  v_c = f_blend(v_c, v_paving, v_stone, cw_thread, cw_block, cw_grid);
  var v_crack: f32 = abs((f_noise2((v_wx * 0.055f), (v_wy * 0.055f), cw_thread, cw_block, cw_grid) - 0.5f));
  v_c = f_blend(v_c, f_color(0.043f, 0.05f, 0.047f, cw_thread, cw_block, cw_grid), ((f_ink((v_crack - 0.008f), 0.007f, cw_thread, cw_block, cw_grid) * v_stone) * 0.65f), cw_thread, cw_block, cw_grid);
  var v_blade: f32 = f_frac(((v_wx * 0.19f) + (floor((v_wy * 0.25f)) * 0.74f)), cw_thread, cw_block, cw_grid);
  var v_grass: f32 = ((f_ink((abs((v_blade - 0.5f)) - 0.07f), 0.07f, cw_thread, cw_block, cw_grid) * f_smooth01(0.6f, 0.83f, v_detail, cw_thread, cw_block, cw_grid)) * (1.0f - v_stone));
  v_c = f_blend(v_c, f_color(0.17f, 0.185f, 0.13f, cw_thread, cw_block, cw_grid), (v_grass * 0.65f), cw_thread, cw_block, cw_grid);
  var v_puddle: f32 = f_smooth01(0.65f, 0.85f, f_noise2(((v_wx * 0.028f) + 4.0f), (v_wy * 0.033f), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  var v_glint: f32 = (f_sat(sin((((v_wx * 0.14f) + (v_wy * 0.07f)) + (v_time * 1.8f))), cw_thread, cw_block, cw_grid) * v_puddle);
  v_c = f_blend(v_c, f_color(0.17f, 0.21f, 0.22f, cw_thread, cw_block, cw_grid), ((v_puddle * 0.16f) + (v_glint * 0.07f)), cw_thread, cw_block, cw_grid);
  var v_wall: f32 = min(abs((abs(v_wx) - 1620.0f)), abs((abs(v_wy) - 1620.0f)));
  if ((v_wall < 15.0f)) {
    var cw_tmp_0: f32;
    if ((abs((abs(v_wx) - 1620.0f)) < abs((abs(v_wy) - 1620.0f)))) {
      cw_tmp_0 = v_wy;
    } else {
      cw_tmp_0 = v_wx;
    }
    var v_along: f32 = cw_tmp_0;
    var v_post: f32 = (abs((f_frac(cw_divide_f32(v_along, 23.0f), cw_thread, cw_block, cw_grid) - 0.5f)) * 23.0f);
    var v_iron: f32 = min(max((v_wall - 2.0f), (v_post - 1.1f)), (abs((v_wall - 8.0f)) - 1.2f));
    v_c = f_blend(v_c, f_color(0.31f, 0.3f, 0.25f, cw_thread, cw_block, cw_grid), f_ink(v_iron, v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  }
  if (((abs(v_wx) > 1627.0f) || (abs(v_wy) > 1627.0f))) {
    v_c = (v_c * vec4<f32>(0.22f));
  }
  var v_ring: f32 = min(abs((v_radial - 94.0f)), min(abs((v_radial - 177.0f)), abs((v_radial - 184.0f))));
  v_c = f_blend(v_c, f_color(0.29f, 0.25f, 0.18f, cw_thread, cw_block, cw_grid), (f_ink((v_ring - 0.8f), v_aa, cw_thread, cw_block, cw_grid) * 0.6f), cw_thread, cw_block, cw_grid);
  var v_angle: f32 = atan2(v_wy, v_wx);
  var v_spokes: f32 = abs(sin((v_angle * 12.0f)));
  if (((v_radial > 149.0f) && (v_radial < 172.0f))) {
    v_c = f_blend(v_c, f_color(0.24f, 0.22f, 0.16f, cw_thread, cw_block, cw_grid), (f_ink((v_spokes - 0.04f), 0.03f, cw_thread, cw_block, cw_grid) * 0.7f), cw_thread, cw_block, cw_grid);
  }
  var v_cross: f32 = min(f_segment(v_wx, v_wy, (-64.0f), (-46.0f), 64.0f, 46.0f, cw_thread, cw_block, cw_grid), f_segment(v_wx, v_wy, (-64.0f), 46.0f, 64.0f, (-46.0f), cw_thread, cw_block, cw_grid));
  if ((v_radial < 80.0f)) {
    v_c = f_blend(v_c, f_color(0.23f, 0.21f, 0.16f, cw_thread, cw_block, cw_grid), f_ink((v_cross - 0.8f), v_aa, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  }
  var v_moon: f32 = (0.8f + (0.12f * f_noise2(((v_wx * 0.003f) + (v_time * 0.015f)), (v_wy * 0.003f), cw_thread, cw_block, cw_grid)));
  var v_lamplight: f32 = (0.75f * exp(cw_divide_f32((-v_pd), 230.0f)));
  v_c = (v_c * vec4<f32>((v_moon + v_lamplight)));
  {
    var v_k: i32 = 0i;
    loop {
      if (!(v_k < 4i)) { break; }
      var cw_tmp_1: f32;
      if (((v_k % 2i) == 0i)) {
        cw_tmp_1 = (-214.0f);
      } else {
        cw_tmp_1 = 214.0f;
      }
      var v_fx: f32 = cw_tmp_1;
      var cw_tmp_2: f32;
      if ((v_k < 2i)) {
        cw_tmp_2 = (-144.0f);
      } else {
        cw_tmp_2 = 144.0f;
      }
      var v_fy: f32 = cw_tmp_2;
      var v_dx: f32 = (v_wx - v_fx);
      var v_dy: f32 = (v_wy - v_fy);
      var v_d: f32 = f_len2(v_dx, v_dy, cw_thread, cw_block, cw_grid);
      var v_flame: f32 = (0.9f + (0.1f * sin(((v_time * 13.0f) + f32(v_k)))));
      var v_glow: f32 = (exp(cw_divide_f32((-v_d), 100.0f)) * v_flame);
      v_c.x = (v_c.x + (v_glow * 0.14f));
      v_c.y = (v_c.y + (v_glow * 0.075f));
      v_c.z = (v_c.z + (v_glow * 0.018f));
      continuing {
        v_k += i32(1);
      }
    }
  }
  if ((b_S[21i] > 0.0f)) {
    var v_r: f32 = (((0.55f - b_S[21i]) * 440.0f) + 25.0f);
    var v_edge: f32 = ((exp(cw_divide_f32((-abs((v_pd - v_r))), 3.0f)) * b_S[21i]) * 1.7f);
    v_c.x = (v_c.x + (v_edge * 0.32f));
    v_c.y = (v_c.y + (v_edge * 0.47f));
    v_c.z = (v_c.z + (v_edge * 0.45f));
  }
  if (((b_S[18i] > 0.0f) && (v_pd < 120.0f))) {
    let cw_argument_index_3 = 24i;
    let cw_argument_index_4 = 23i;
    var v_a: f32 = (atan2((v_wy - b_S[1i]), (v_wx - b_S[0i])) - atan2(b_S[cw_argument_index_3], b_S[cw_argument_index_4]));
    var v_arc: f32 = cos((v_a + ((cw_divide_f32(b_S[18i], 0.24f) - 0.5f) * 1.5f)));
    var v_slash: f32 = (((exp(cw_divide_f32((-abs((v_pd - 84.0f))), 3.0f)) * f_sat(((v_arc - 0.15f) * 2.0f), cw_thread, cw_block, cw_grid)) * b_S[18i]) * 3.8f);
    v_c.x = (v_c.x + (v_slash * 0.65f));
    v_c.y = (v_c.y + (v_slash * 0.71f));
    v_c.z = (v_c.z + (v_slash * 0.64f));
  }
  if ((b_S[14i] > 0.0f)) {
    let cw_argument_index_9 = 0i;
    let cw_argument_index_10 = 1i;
    var v_trail: f32 = (exp(cw_divide_f32((-f_segment(v_wx, v_wy, b_S[cw_argument_index_9], b_S[cw_argument_index_10], (b_S[0i] - (b_S[2i] * 0.08f)), (b_S[1i] - (b_S[3i] * 0.08f)), cw_thread, cw_block, cw_grid)), 10.0f)) * 0.33f);
    v_c.x = (v_c.x + (v_trail * 0.25f));
    v_c.y = (v_c.y + (v_trail * 0.5f));
    v_c.z = (v_c.z + (v_trail * 0.5f));
  }
  b_Pixels[((v_iy * cw_params.p_width) + v_ix)] = f_rgba(v_c, cw_thread, cw_block, cw_grid);
}
