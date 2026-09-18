// CUDA WebShader 0.1.0. Generated from kernel buildTiles.
@group(0) @binding(0) var<storage, read> b_S: array<f32>;
@group(0) @binding(1) var<storage, read> b_E: array<f32>;
@group(0) @binding(2) var<storage, read> b_P: array<f32>;
@group(0) @binding(3) var<storage, read_write> b_Tiles: array<i32>;
struct CWParams {
  p_width: i32,
  p_height: i32,
  cw_pad_8: u32,
  cw_pad_12: u32,
}
@group(0) @binding(4) var<uniform> cw_params: CWParams;
const cw_block_size: vec3<u32> = vec3<u32>(64u, 1u, 1u);

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

@compute @workgroup_size(64, 1, 1)
fn main(
  @builtin(local_invocation_id) cw_thread: vec3<u32>,
  @builtin(workgroup_id) cw_block: vec3<u32>,
  @builtin(num_workgroups) cw_grid: vec3<u32>
) {
  var v_id: i32 = i32(((cw_block.x * cw_block_size.x) + cw_thread.x));
  var v_tw: i32 = ((cw_params.p_width + 31i) / 32i);
  var v_th: i32 = ((cw_params.p_height + 31i) / 32i);
  if ((v_id >= (v_tw * v_th))) {
    return;
  }
  var v_b: i32 = (v_id * 128i);
  var v_count: i32 = 0i;
  var v_cx: f32 = f32((((v_id % v_tw) * 32i) + (32i / 2i)));
  var v_cy: f32 = f32((((v_id / v_tw) * 32i) + (32i / 2i)));
  var v_zoom: f32 = cw_divide_f32(f32(cw_params.p_height), 700.0f);
  var v_reach: f32 = ((42.0f * v_zoom) + 16.0f);
  {
    var v_i: i32 = 0i;
    loop {
      if (!(v_i < 320i)) { break; }
      if ((b_E[((v_i * 48i) + 4i)] > 0.0f)) {
        var v_sx: f32 = (((b_E[(v_i * 48i)] - b_S[25i]) * v_zoom) + (f32(cw_params.p_width) * 0.5f));
        var v_sy: f32 = (((b_E[((v_i * 48i) + 1i)] - b_S[26i]) * v_zoom) + (f32(cw_params.p_height) * 0.5f));
        if ((((abs((v_sx - v_cx)) < v_reach) && (abs(((v_sy - (16.0f * v_zoom)) - v_cy)) < (v_reach + (10.0f * v_zoom)))) && (v_count < (128i - 1i)))) {
          b_Tiles[((v_b + 1i) + v_count)] = v_i;
          v_count += i32(1);
        }
      }
      continuing {
        v_i += i32(1);
      }
    }
  }
  {
    var v_i: i32 = 0i;
    loop {
      if (!(v_i < 128i)) { break; }
      if ((b_P[((v_i * 10i) + 6i)] > 0.0f)) {
        var v_sx: f32 = (((b_P[(v_i * 10i)] - b_S[25i]) * v_zoom) + (f32(cw_params.p_width) * 0.5f));
        var v_sy: f32 = (((b_P[((v_i * 10i) + 1i)] - b_S[26i]) * v_zoom) + (f32(cw_params.p_height) * 0.5f));
        if ((((abs((v_sx - v_cx)) < ((25.0f * v_zoom) + 16.0f)) && (abs((v_sy - v_cy)) < ((25.0f * v_zoom) + 16.0f))) && (v_count < (128i - 1i)))) {
          b_Tiles[((v_b + 1i) + v_count)] = (1000i + v_i);
          v_count += i32(1);
        }
      }
      continuing {
        v_i += i32(1);
      }
    }
  }
  {
    var v_i: i32 = 0i;
    loop {
      if (!(v_i < 320i)) { break; }
      if (((b_E[((v_i * 48i) + 4i)] > 0.0f) && (b_E[((v_i * 48i) + 33i)] > 0.0f))) {
        var v_sx: f32 = (((b_E[((v_i * 48i) + 29i)] - b_S[25i]) * v_zoom) + (f32(cw_params.p_width) * 0.5f));
        var v_sy: f32 = (((b_E[((v_i * 48i) + 30i)] - b_S[26i]) * v_zoom) + (f32(cw_params.p_height) * 0.5f));
        if ((((abs((v_sx - v_cx)) < ((22.0f * v_zoom) + 16.0f)) && (abs((v_sy - v_cy)) < ((22.0f * v_zoom) + 16.0f))) && (v_count < (128i - 1i)))) {
          b_Tiles[((v_b + 1i) + v_count)] = (2000i + v_i);
          v_count += i32(1);
        }
      }
      continuing {
        v_i += i32(1);
      }
    }
  }
  {
    var v_i: i32 = 0i;
    loop {
      if (!(v_i < 320i)) { break; }
      if ((b_E[((v_i * 48i) + 4i)] < 0.0f)) {
        var v_sx: f32 = (((b_E[(v_i * 48i)] - b_S[25i]) * v_zoom) + (f32(cw_params.p_width) * 0.5f));
        var v_sy: f32 = (((b_E[((v_i * 48i) + 1i)] - b_S[26i]) * v_zoom) + (f32(cw_params.p_height) * 0.5f));
        if ((((abs((v_sx - v_cx)) < v_reach) && (abs(((v_sy - (16.0f * v_zoom)) - v_cy)) < (v_reach + (10.0f * v_zoom)))) && (v_count < (128i - 1i)))) {
          b_Tiles[((v_b + 1i) + v_count)] = v_i;
          v_count += i32(1);
        }
      }
      continuing {
        v_i += i32(1);
      }
    }
  }
  b_Tiles[v_b] = v_count;
}
