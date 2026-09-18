// CUDA WebShader 0.1.0. Generated from kernel stepEnemies.
@group(0) @binding(0) var<storage, read> b_S: array<f32>;
@group(0) @binding(1) var<storage, read> b_Old: array<f32>;
@group(0) @binding(2) var<storage, read_write> b_E: array<f32>;
@group(0) @binding(3) var<storage, read> b_P: array<f32>;
@group(0) @binding(4) var<storage, read> b_G: array<f32>;
@group(0) @binding(5) var<storage, read> b_Brain: array<f32>;
struct CWParams {
  p_dt: f32,
  p_aspect: f32,
  cw_pad_8: u32,
  cw_pad_12: u32,
}
@group(0) @binding(6) var<uniform> cw_params: CWParams;
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

@compute @workgroup_size(64, 1, 1)
fn main(
  @builtin(local_invocation_id) cw_thread: vec3<u32>,
  @builtin(workgroup_id) cw_block: vec3<u32>,
  @builtin(num_workgroups) cw_grid: vec3<u32>
) {
  var v_i: i32 = i32(((cw_block.x * cw_block_size.x) + cw_thread.x));
  if ((v_i >= 320i)) {
    return;
  }
  var v_b: i32 = (v_i * 48i);
  {
    var v_j: i32 = 0i;
    loop {
      if (!(v_j < 48i)) { break; }
      b_E[(v_b + v_j)] = b_Old[(v_b + v_j)];
      continuing {
        v_j += i32(1);
      }
    }
  }
  if ((b_S[49i] > 0.5f)) {
    {
      var v_j: i32 = 0i;
      loop {
        if (!(v_j < 48i)) { break; }
        b_E[(v_b + v_j)] = 0.0f;
        continuing {
          v_j += i32(1);
        }
      }
    }
    return;
  }
  if ((b_S[61i] > 0.5f)) {
    b_E[(v_b + 19i)] = 0.0f;
    b_E[(v_b + 20i)] = 0.0f;
    b_E[(v_b + 21i)] = 0.0f;
  }
  if (((b_S[8i] != 1.0f) || (b_S[51i] < 0.5f))) {
    return;
  }
  var v_px: f32 = b_S[0i];
  var v_py: f32 = b_S[1i];
  var v_ex: f32 = b_Old[v_b];
  var v_ey: f32 = b_Old[(v_b + 1i)];
  var v_hp: f32 = b_Old[(v_b + 4i)];
  if ((v_hp <= 0.0f)) {
    if ((v_hp < 0.0f)) {
      b_E[(v_b + 18i)] = (b_E[(v_b + 18i)] + cw_params.p_dt);
      var v_dx: f32 = (v_px - v_ex);
      var v_dy: f32 = (v_py - v_ey);
      var v_dist: f32 = max(1.0f, f_len2(v_dx, v_dy, cw_thread, cw_block, cw_grid));
      if (((b_E[(v_b + 38i)] > 0.0f) && (v_dist < (b_S[36i] + 40.0f)))) {
        b_E[v_b] = (b_E[v_b] + ((cw_divide_f32(v_dx, v_dist) * 260.0f) * cw_params.p_dt));
        b_E[(v_b + 1i)] = (b_E[(v_b + 1i)] + ((cw_divide_f32(v_dy, v_dist) * 260.0f) * cw_params.p_dt));
      }
      if (((b_E[(v_b + 38i)] > 0.0f) && (v_dist < 22.0f))) {
        b_E[(v_b + 21i)] = b_E[(v_b + 38i)];
        b_E[(v_b + 38i)] = 0.0f;
      }
      if (((b_E[(v_b + 18i)] > 16.0f) || ((b_E[(v_b + 38i)] <= 0.0f) && (b_E[(v_b + 18i)] > 3.0f)))) {
        b_E[(v_b + 4i)] = 0.0f;
      }
    }
    {
      var v_j: i32 = 0i;
      loop {
        if (!(v_j < 5i)) { break; }
        var v_serial: i32 = (i32(b_S[29i]) + v_j);
        if ((((v_j < i32(b_S[30i])) && ((v_serial % 320i) == v_i)) && (b_E[(v_b + 4i)] == 0.0f))) {
          var v_seed: f32 = (f32(v_serial) + (b_S[48i] * 11.0f));
          var v_angle: f32 = ((f_hashf(v_seed, cw_thread, cw_block, cw_grid) * 3.14159265359f) * 2.0f);
          var v_edge: f32 = max(cw_divide_f32(abs(cos(v_angle)), max(0.1f, cw_params.p_aspect)), abs(sin(v_angle)));
          var v_radius: f32 = (cw_divide_f32(380.0f, max(0.1f, v_edge)) + (40.0f * f_hashf((v_seed + 2.0f), cw_thread, cw_block, cw_grid)));
          var v_x: f32 = (v_px + (cos(v_angle) * v_radius));
          var v_y: f32 = (v_py + (sin(v_angle) * v_radius));
          var v_type: i32 = i32((f_hashf((v_seed + 3.0f), cw_thread, cw_block, cw_grid) * 5.0f));
          if ((b_S[6i] < 12.0f)) {
            v_type = 0i;
          }
          var v_health: f32 = (35.0f + (b_S[6i] * 0.1f));
          if ((v_type == 1i)) {
            v_health = (v_health * 0.75f);
          }
          if ((v_type == 3i)) {
            v_health = (v_health * 3.2f);
          }
          var v_elite: bool = ((v_serial > 0i) && ((v_serial % 110i) == 0i));
          if (v_elite) {
            v_type = 3i;
            v_health = (v_health * 4.0f);
          }
          {
            var v_k: i32 = 0i;
            loop {
              if (!(v_k < 48i)) { break; }
              b_E[(v_b + v_k)] = 0.0f;
              continuing {
                v_k += i32(1);
              }
            }
          }
          b_E[v_b] = v_x;
          b_E[(v_b + 1i)] = v_y;
          b_E[(v_b + 4i)] = v_health;
          b_E[(v_b + 5i)] = v_health;
          b_E[(v_b + 6i)] = f32(v_type);
          b_E[(v_b + 12i)] = (f_hashf((v_seed + 7.0f), cw_thread, cw_block, cw_grid) * 6.28f);
          b_E[(v_b + 13i)] = f32(((v_type * 8i) + (v_serial % 8i)));
          b_E[(v_b + 14i)] = (-1.0f);
          b_E[(v_b + 15i)] = b_S[19i];
          b_E[(v_b + 16i)] = b_S[22i];
          b_E[(v_b + 24i)] = b_G[((((v_type * 8i) + (v_serial % 8i)) * 16i) + 8i)];
          {
            var v_k: i32 = 0i;
            loop {
              if (!(v_k < 6i)) { break; }
              b_E[((v_b + 40i) + v_k)] = b_G[((((v_type * 8i) + (v_serial % 8i)) * 16i) + v_k)];
              continuing {
                v_k += i32(1);
              }
            }
          }
          var cw_tmp_0: f32;
          if (v_elite) {
            cw_tmp_0 = 1.0f;
          } else {
            cw_tmp_0 = 0.0f;
          }
          b_E[(v_b + 35i)] = cw_tmp_0;
          b_E[(v_b + 36i)] = f32(v_serial);
          b_E[(v_b + 37i)] = v_seed;
          b_E[(v_b + 10i)] = 1.0f;
        }
        continuing {
          v_j += i32(1);
        }
      }
    }
    return;
  }
  var v_type: i32 = i32(b_Old[(v_b + 6i)]);
  var v_gb: i32 = (i32(b_Old[(v_b + 13i)]) * 16i);
  var v_dx: f32 = (v_px - v_ex);
  var v_dy: f32 = (v_py - v_ey);
  var v_dist: f32 = max(0.001f, f_len2(v_dx, v_dy, cw_thread, cw_block, cw_grid));
  var v_ux: f32 = cw_divide_f32(v_dx, v_dist);
  var v_uy: f32 = cw_divide_f32(v_dy, v_dist);
  var cw_tmp_1: f32;
  if ((v_type == 3i)) {
    cw_tmp_1 = 18.0f;
  } else {
    cw_tmp_1 = 11.0f;
  }
  var v_radius: f32 = cw_tmp_1;
  if ((b_Old[(v_b + 35i)] > 0.5f)) {
    v_radius = (v_radius * 1.5f);
  }
  b_E[(v_b + 7i)] = (b_E[(v_b + 7i)] + cw_params.p_dt);
  b_E[(v_b + 9i)] = (b_E[(v_b + 9i)] - cw_params.p_dt);
  b_E[(v_b + 10i)] = (b_E[(v_b + 10i)] - cw_params.p_dt);
  b_E[(v_b + 17i)] = max(0.0f, (b_Old[(v_b + 17i)] - cw_params.p_dt));
  b_E[(v_b + 11i)] = max(0.0f, (b_Old[(v_b + 11i)] - (cw_params.p_dt * 0.11f)));
  if ((v_dist < 170.0f)) {
    b_E[(v_b + 22i)] = (b_E[(v_b + 22i)] + cw_params.p_dt);
  }
  var v_dealt: f32 = 0.0f;
  var v_cause: f32 = 0.0f;
  {
    var v_j: i32 = 0i;
    loop {
      if (!(v_j < 128i)) { break; }
      var v_q: i32 = (v_j * 10i);
      if (((((b_P[(v_q + 6i)] > 0.0f) && (b_P[(v_q + 8i)] > b_Old[(v_b + 14i)])) && (abs((b_P[v_q] - v_ex)) < 35.0f)) && (abs((b_P[(v_q + 1i)] - v_ey)) < 35.0f))) {
        let cw_argument_index_2 = (v_q + 2i);
        let cw_argument_index_3 = (v_q + 3i);
        let cw_argument_index_4 = v_q;
        let cw_argument_index_5 = (v_q + 1i);
        if ((f_segment(v_ex, v_ey, b_P[cw_argument_index_2], b_P[cw_argument_index_3], b_P[cw_argument_index_4], b_P[cw_argument_index_5], cw_thread, cw_block, cw_grid) < (v_radius + b_P[(v_q + 9i)]))) {
          v_dealt = (v_dealt + b_P[(v_q + 7i)]);
          v_cause = 1.0f;
          let cw_argument_index_6 = (v_b + 14i);
          let cw_argument_index_7 = (v_q + 8i);
          b_E[(v_b + 14i)] = max(b_E[cw_argument_index_6], b_P[cw_argument_index_7]);
        }
      }
      continuing {
        v_j += i32(1);
      }
    }
  }
  var v_facing: f32 = (((-v_ux) * b_S[23i]) - (v_uy * b_S[24i]));
  if (((((b_S[18i] > 0.0f) && (b_S[19i] != b_Old[(v_b + 15i)])) && (v_dist < 112.0f)) && (v_facing > (-0.2f)))) {
    v_dealt = (v_dealt + (b_S[32i] * 2.0f));
    v_cause = 2.0f;
    b_E[(v_b + 15i)] = b_S[19i];
  }
  if ((((b_S[21i] > 0.0f) && (b_S[22i] != b_Old[(v_b + 16i)])) && (v_dist < (((0.55f - b_S[21i]) * 440.0f) + 25.0f)))) {
    v_dealt = (v_dealt + (b_S[32i] * 2.8f));
    v_cause = 3.0f;
    b_E[(v_b + 16i)] = b_S[22i];
    b_E[(v_b + 11i)] = 1.0f;
  }
  if (((b_S[37i] > 0.0f) && (b_E[(v_b + 17i)] <= 0.0f))) {
    {
      var v_k: i32 = 0i;
      loop {
        if (!(v_k < 5i)) { break; }
        if ((f32(v_k) < b_S[37i])) {
          var v_a: f32 = ((b_S[6i] * 2.2f) + cw_divide_f32(((f32(v_k) * 3.14159265359f) * 2.0f), b_S[37i]));
          var v_ox: f32 = (v_px + (cos(v_a) * 78.0f));
          var v_oy: f32 = (v_py + (sin(v_a) * 78.0f));
          if ((f_len2((v_ex - v_ox), (v_ey - v_oy), cw_thread, cw_block, cw_grid) < (v_radius + 11.0f))) {
            v_dealt = (v_dealt + (b_S[32i] * 0.65f));
            v_cause = 4.0f;
          }
        }
        continuing {
          v_k += i32(1);
        }
      }
    }
  }
  if ((v_dealt > 0.0f)) {
    v_hp = (v_hp - v_dealt);
    b_E[(v_b + 17i)] = 0.13f;
    b_E[(v_b + 11i)] = min(1.0f, (b_E[(v_b + 11i)] + 0.25f));
    b_E[(v_b + 25i)] = ((-v_ux) * 110.0f);
    b_E[(v_b + 26i)] = ((-v_uy) * 110.0f);
  }
  if ((v_hp <= 0.0f)) {
    b_E[(v_b + 4i)] = (-1.0f);
    b_E[(v_b + 19i)] = 1.0f;
    b_E[(v_b + 46i)] = v_cause;
    var cw_tmp_9: f32;
    if ((b_Old[(v_b + 35i)] > 0.5f)) {
      cw_tmp_9 = 25.0f;
    } else {
      var cw_tmp_8: f32;
      if ((v_type == 3i)) {
        cw_tmp_8 = 6.0f;
      } else {
        cw_tmp_8 = 3.0f;
      }
      cw_tmp_9 = cw_tmp_8;
    }
    b_E[(v_b + 38i)] = cw_tmp_9;
    b_E[(v_b + 18i)] = 0.0f;
    b_E[(v_b + 33i)] = 0.0f;
    return;
  }
  b_E[(v_b + 4i)] = v_hp;
  var v_trust: f32 = b_Brain[4i];
  var v_lx: f32 = f_mixf(max((-210.0f), min(210.0f, (b_S[2i] * 0.5f))), (b_Brain[8i] * 140.0f), v_trust, cw_thread, cw_block, cw_grid);
  var v_ly: f32 = f_mixf(max((-210.0f), min(210.0f, (b_S[3i] * 0.5f))), (b_Brain[9i] * 140.0f), v_trust, cw_thread, cw_block, cw_grid);
  var v_tx: f32 = (v_px + ((v_lx * b_Old[(v_b + 40i)]) * 1.7f));
  var v_ty: f32 = (v_py + ((v_ly * b_Old[(v_b + 40i)]) * 1.7f));
  var cw_tmp_10: f32;
  if ((b_Old[(v_b + 12i)] < 3.14159265359f)) {
    cw_tmp_10 = (-1.0f);
  } else {
    cw_tmp_10 = 1.0f;
  }
  var v_orbit: f32 = cw_tmp_10;
  var v_state: i32 = i32(b_Old[(v_b + 8i)]);
  if (((b_E[(v_b + 9i)] <= 0.0f) && (v_state < 4i))) {
    var v_r: f32 = f_hashf((b_Old[(v_b + 37i)] + floor((b_S[6i] * 3.0f))), cw_thread, cw_block, cw_grid);
    v_state = 0i;
    if (((v_dist > 80.0f) && (v_r < b_Old[(v_b + 41i)]))) {
      v_state = 1i;
    }
    if (((v_dist > 190.0f) && (v_r > ((0.89f + (b_Old[(v_b + 45i)] * 0.08f)) - (b_Old[(v_b + 43i)] * 0.06f))))) {
      v_state = 2i;
    }
    if (((v_hp < (b_Old[(v_b + 5i)] * 0.4f)) && (v_r < b_Old[(v_b + 43i)]))) {
      v_state = 3i;
    }
    b_E[(v_b + 9i)] = (0.22f + (0.38f * f_hashf((b_Old[(v_b + 37i)] + b_S[7i]), cw_thread, cw_block, cw_grid)));
  }
  var v_speed: f32 = 69.0f;
  if ((v_type == 1i)) {
    v_speed = 113.0f;
  }
  if ((v_type == 2i)) {
    v_speed = 65.0f;
  }
  if ((v_type == 3i)) {
    v_speed = 49.0f;
  }
  if ((v_type == 4i)) {
    v_speed = 93.0f;
  }
  v_speed = (v_speed * (1.0f + min(0.28f, cw_divide_f32(b_S[6i], 1600.0f))));
  var v_vx: f32 = 0.0f;
  var v_vy: f32 = 0.0f;
  if ((v_state == 1i)) {
    v_tx = (v_tx + (((-v_uy) * v_orbit) * (60.0f + (b_Old[(v_b + 41i)] * 90.0f))));
    v_ty = (v_ty + ((v_ux * v_orbit) * (60.0f + (b_Old[(v_b + 41i)] * 90.0f))));
  }
  var v_td: f32 = max(1.0f, f_len2((v_tx - v_ex), (v_ty - v_ey), cw_thread, cw_block, cw_grid));
  v_vx = (cw_divide_f32((v_tx - v_ex), v_td) * v_speed);
  v_vy = (cw_divide_f32((v_ty - v_ey), v_td) * v_speed);
  if ((v_state == 2i)) {
    v_vx = 0.0f;
    v_vy = 0.0f;
  }
  if ((v_state == 3i)) {
    v_vx = ((((-v_ux) * v_speed) * 0.65f) - ((v_uy * v_orbit) * 25.0f));
    v_vy = ((((-v_uy) * v_speed) * 0.65f) + ((v_ux * v_orbit) * 25.0f));
  }
  if ((((v_type == 2i) && (v_dist < (165.0f + (b_Old[(v_b + 42i)] * 145.0f)))) && (v_state < 4i))) {
    v_vx = ((((-v_ux) * v_speed) * 0.65f) - ((v_uy * v_orbit) * 40.0f));
    v_vy = ((((-v_uy) * v_speed) * 0.65f) + ((v_ux * v_orbit) * 40.0f));
  }
  if ((((v_state < 4i) && (b_Old[(v_b + 11i)] > 0.1f)) && (v_facing > 0.65f))) {
    v_vx = (v_vx + ((((-v_uy) * v_orbit) * b_Old[(v_b + 43i)]) * 80.0f));
    v_vy = (v_vy + (((v_ux * v_orbit) * b_Old[(v_b + 43i)]) * 80.0f));
  }
  var cw_tmp_14: bool = ((v_state < 4i) && (b_E[(v_b + 10i)] <= 0.0f));
  if (cw_tmp_14) {
    var cw_tmp_13: bool = ((v_type == 2i) && (v_dist < 410.0f));
    if (!cw_tmp_13) {
      var cw_tmp_12: bool = (v_type != 2i);
      if (cw_tmp_12) {
        var cw_tmp_11: f32;
        if ((v_type == 1i)) {
          cw_tmp_11 = (70.0f + (b_Old[(v_b + 42i)] * 50.0f));
        } else {
          cw_tmp_11 = (36.0f + (b_Old[(v_b + 42i)] * 28.0f));
        }
        cw_tmp_12 = (v_dist < cw_tmp_11);
      }
      cw_tmp_13 = cw_tmp_12;
    }
    cw_tmp_14 = cw_tmp_13;
  }
  if (cw_tmp_14) {
    v_state = 4i;
    var cw_tmp_15: f32;
    if ((v_type == 3i)) {
      cw_tmp_15 = 0.7f;
    } else {
      cw_tmp_15 = 0.48f;
    }
    b_E[(v_b + 34i)] = cw_tmp_15;
    b_E[(v_b + 27i)] = cw_divide_f32((v_tx - v_ex), v_td);
    b_E[(v_b + 28i)] = cw_divide_f32((v_ty - v_ey), v_td);
  }
  if ((v_state == 4i)) {
    v_vx = 0.0f;
    v_vy = 0.0f;
    b_E[(v_b + 34i)] = (b_E[(v_b + 34i)] - cw_params.p_dt);
    if ((b_E[(v_b + 34i)] <= 0.0f)) {
      if ((v_type == 2i)) {
        b_E[(v_b + 29i)] = v_ex;
        b_E[(v_b + 30i)] = (v_ey - 10.0f);
        b_E[(v_b + 31i)] = (b_E[(v_b + 27i)] * 210.0f);
        b_E[(v_b + 32i)] = (b_E[(v_b + 28i)] * 210.0f);
        b_E[(v_b + 33i)] = 2.5f;
        v_state = 0i;
        b_E[(v_b + 10i)] = (1.9f + ((1.0f - b_Old[(v_b + 45i)]) * 1.1f));
      } else {
        v_state = 5i;
        b_E[(v_b + 34i)] = 0.22f;
        b_E[(v_b + 10i)] = (1.05f + ((1.0f - b_Old[(v_b + 45i)]) * 0.65f));
      }
    }
  }
  if ((v_state == 5i)) {
    b_E[(v_b + 34i)] = (b_E[(v_b + 34i)] - cw_params.p_dt);
    var cw_tmp_16: f32;
    if ((v_type == 3i)) {
      cw_tmp_16 = 170.0f;
    } else {
      cw_tmp_16 = 275.0f;
    }
    v_vx = (b_E[(v_b + 27i)] * cw_tmp_16);
    var cw_tmp_17: f32;
    if ((v_type == 3i)) {
      cw_tmp_17 = 170.0f;
    } else {
      cw_tmp_17 = 275.0f;
    }
    v_vy = (b_E[(v_b + 28i)] * cw_tmp_17);
    if (((v_dist < (v_radius + 15.0f)) && (b_Old[(v_b + 10i)] > 0.8f))) {
      var cw_tmp_18: f32;
      if ((v_type == 3i)) {
        cw_tmp_18 = 20.0f;
      } else {
        cw_tmp_18 = 11.0f;
      }
      b_E[(v_b + 20i)] = cw_tmp_18;
      b_E[(v_b + 10i)] = 0.75f;
    }
    if ((b_E[(v_b + 34i)] <= 0.0f)) {
      v_state = 0i;
    }
  }
  b_E[(v_b + 8i)] = f32(v_state);
  if ((b_E[(v_b + 33i)] > 0.0f)) {
    var v_sx: f32 = b_E[(v_b + 29i)];
    var v_sy: f32 = b_E[(v_b + 30i)];
    b_E[(v_b + 29i)] = (b_E[(v_b + 29i)] + (b_E[(v_b + 31i)] * cw_params.p_dt));
    b_E[(v_b + 30i)] = (b_E[(v_b + 30i)] + (b_E[(v_b + 32i)] * cw_params.p_dt));
    b_E[(v_b + 33i)] = (b_E[(v_b + 33i)] - cw_params.p_dt);
    let cw_argument_index_19 = (v_b + 29i);
    let cw_argument_index_20 = (v_b + 30i);
    if ((f_segment(v_px, v_py, v_sx, v_sy, b_E[cw_argument_index_19], b_E[cw_argument_index_20], cw_thread, cw_block, cw_grid) < 13.0f)) {
      b_E[(v_b + 20i)] = (b_E[(v_b + 20i)] + 12.0f);
      b_E[(v_b + 33i)] = 0.0f;
    }
  }
  {
    var v_k: i32 = 1i;
    loop {
      if (!(v_k <= 12i)) { break; }
      var v_n: i32 = (((v_i + (v_k * 23i)) % 320i) * 48i);
      if ((b_Old[(v_n + 4i)] > 0.0f)) {
        var v_sx: f32 = (v_ex - b_Old[v_n]);
        var v_sy: f32 = (v_ey - b_Old[(v_n + 1i)]);
        var v_sd: f32 = f_len2(v_sx, v_sy, cw_thread, cw_block, cw_grid);
        var v_space: f32 = (22.0f + (b_Old[(v_b + 44i)] * 17.0f));
        if (((v_sd > 0.1f) && (v_sd < v_space))) {
          v_vx = (v_vx + ((cw_divide_f32(v_sx, v_sd) * (v_space - v_sd)) * 2.4f));
          v_vy = (v_vy + ((cw_divide_f32(v_sy, v_sd) * (v_space - v_sd)) * 2.4f));
        }
      }
      continuing {
        v_k += i32(1);
      }
    }
  }
  v_vx = (v_vx + b_E[(v_b + 25i)]);
  v_vy = (v_vy + b_E[(v_b + 26i)]);
  b_E[(v_b + 25i)] = (b_E[(v_b + 25i)] * 0.8f);
  b_E[(v_b + 26i)] = (b_E[(v_b + 26i)] * 0.8f);
  var v_xx: f32 = (v_ex + (v_vx * cw_params.p_dt));
  var v_yy: f32 = (v_ey + (v_vy * cw_params.p_dt));
  if ((f_obstacle(v_xx, v_ey, cw_thread, cw_block, cw_grid) > (v_radius * 0.7f))) {
    v_ex = v_xx;
  } else {
    v_ey = (v_ey + ((v_orbit * v_speed) * cw_params.p_dt));
  }
  if ((f_obstacle(v_ex, v_yy, cw_thread, cw_block, cw_grid) > (v_radius * 0.7f))) {
    v_ey = v_yy;
  } else {
    v_ex = (v_ex + ((v_orbit * v_speed) * cw_params.p_dt));
  }
  b_E[v_b] = v_ex;
  b_E[(v_b + 1i)] = v_ey;
  b_E[(v_b + 2i)] = v_vx;
  b_E[(v_b + 3i)] = v_vy;
  if ((v_dist > 1600.0f)) {
    b_E[(v_b + 4i)] = 0.0f;
    b_E[(v_b + 33i)] = 0.0f;
  }
}
