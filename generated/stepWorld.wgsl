// CUDA WebShader 0.1.0. Generated from kernel stepWorld.
@group(0) @binding(0) var<storage, read_write> b_S: array<f32>;
@group(0) @binding(1) var<storage, read_write> b_E: array<f32>;
@group(0) @binding(2) var<storage, read> b_I: array<f32>;
@group(0) @binding(3) var<storage, read_write> b_G: array<f32>;
struct CWParams {
  p_aspect: f32,
  p_dt: f32,
  cw_pad_8: u32,
  cw_pad_12: u32,
}
@group(0) @binding(4) var<uniform> cw_params: CWParams;
const cw_block_size: vec3<u32> = vec3<u32>(1u, 1u, 1u);

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

@compute @workgroup_size(1, 1, 1)
fn main(
  @builtin(local_invocation_id) cw_thread: vec3<u32>,
  @builtin(workgroup_id) cw_block: vec3<u32>,
  @builtin(num_workgroups) cw_grid: vec3<u32>
) {
  if (((cw_thread.x != u32(0i)) || (cw_block.x != u32(0i)))) {
    return;
  }
  b_S[46i] = (b_S[46i] + cw_params.p_dt);
  b_S[49i] = 0.0f;
  b_S[44i] = 0.0f;
  b_S[30i] = 0.0f;
  b_S[51i] = 0.0f;
  b_S[61i] = 0.0f;
  var v_mode: i32 = i32(b_S[8i]);
  var v_click: bool = ((b_I[4i] > 0.5f) && (b_S[64i] < 0.5f));
  b_S[64i] = b_I[4i];
  var v_start: bool = (((b_I[8i] > 0.5f) && (b_S[68i] < 0.5f)) || ((v_mode == 0i) && v_click));
  var v_pause: bool = ((b_I[9i] > 0.5f) && (b_S[69i] < 0.5f));
  var v_aut: bool = ((b_I[11i] > 0.5f) && (b_S[71i] < 0.5f));
  var v_restart: bool = ((b_I[12i] > 0.5f) && (b_S[72i] < 0.5f));
  var v_learning: bool = ((b_I[13i] > 0.5f) && (b_S[73i] < 0.5f));
  b_S[68i] = b_I[8i];
  b_S[69i] = b_I[9i];
  b_S[71i] = b_I[11i];
  b_S[72i] = b_I[12i];
  b_S[73i] = b_I[13i];
  if (((b_I[14i] > 0.5f) && (b_S[74i] < 0.5f))) {
    b_S[47i] = (1.0f - b_S[47i]);
  }
  b_S[74i] = b_I[14i];
  if ((b_S[76i] < 0.5f)) {
    var cw_tmp_0: f32;
    if ((b_I[15i] > 0.5f)) {
      cw_tmp_0 = 1.0f;
    } else {
      cw_tmp_0 = 0.0f;
    }
    b_S[31i] = cw_tmp_0;
    b_S[76i] = 1.0f;
  }
  if ((((v_mode == 0i) && v_start) || (((v_mode == 4i) || (v_mode == 5i)) && (v_start || v_restart)))) {
    var v_seed: f32 = (b_S[48i] + 79.0f);
    var v_learn: f32 = b_S[45i];
    var v_anim: f32 = b_S[46i];
    var v_autoFire: f32 = b_S[31i];
    {
      var v_j: i32 = 0i;
      loop {
        if (!(v_j < 64i)) { break; }
        b_S[v_j] = 0.0f;
        continuing {
          v_j += i32(1);
        }
      }
    }
    b_S[48i] = v_seed;
    b_S[46i] = v_anim;
    b_S[4i] = 100.0f;
    b_S[5i] = 100.0f;
    b_S[10i] = 1.0f;
    b_S[11i] = 14.0f;
    b_S[23i] = 1.0f;
    b_S[31i] = v_autoFire;
    b_S[32i] = 20.0f;
    b_S[33i] = 1.0f;
    b_S[34i] = 1.0f;
    b_S[35i] = 1.0f;
    b_S[36i] = 85.0f;
    b_S[45i] = v_learn;
    b_S[8i] = 1.0f;
    b_S[49i] = 1.0f;
    return;
  }
  if (((v_pause || (v_start && (v_mode == 2i))) && ((v_mode == 1i) || (v_mode == 2i)))) {
    var cw_tmp_1: f32;
    if ((v_mode == 1i)) {
      cw_tmp_1 = 2.0f;
    } else {
      cw_tmp_1 = 1.0f;
    }
    b_S[8i] = cw_tmp_1;
    return;
  }
  if (v_learning) {
    b_S[45i] = (1.0f - b_S[45i]);
  }
  if (v_aut) {
    b_S[31i] = (1.0f - b_S[31i]);
  }
  if ((v_mode == 3i)) {
    var v_choice: i32 = (i32(b_I[10i]) - 1i);
    if (v_click) {
      var v_vw: f32 = (cw_params.p_aspect * 720.0f);
      var v_mx: f32 = (((b_I[2i] + 1.0f) * v_vw) * 0.5f);
      var v_my: f32 = ((b_I[3i] + 1.0f) * 360.0f);
      {
        var v_k: i32 = 0i;
        loop {
          if (!(v_k < 3i)) { break; }
          var cw_tmp_2: f32;
          if ((v_vw < 850.0f)) {
            cw_tmp_2 = (v_vw * 0.5f);
          } else {
            cw_tmp_2 = ((v_vw * 0.5f) + (f32((v_k - 1i)) * 280.0f));
          }
          var v_bx: f32 = cw_tmp_2;
          var cw_tmp_3: f32;
          if ((v_vw < 850.0f)) {
            cw_tmp_3 = (282.0f + (f32(v_k) * 133.0f));
          } else {
            cw_tmp_3 = 390.0f;
          }
          var v_by: f32 = cw_tmp_3;
          var cw_tmp_4: f32;
          if ((v_vw < 850.0f)) {
            cw_tmp_4 = (v_vw - 40.0f);
          } else {
            cw_tmp_4 = 254.0f;
          }
          var v_ww: f32 = cw_tmp_4;
          var cw_tmp_5: f32;
          if ((v_vw < 850.0f)) {
            cw_tmp_5 = 116.0f;
          } else {
            cw_tmp_5 = 234.0f;
          }
          var v_hh: f32 = cw_tmp_5;
          if (((abs((v_mx - v_bx)) < (v_ww * 0.5f)) && (abs((v_my - v_by)) < (v_hh * 0.5f)))) {
            v_choice = v_k;
          }
          continuing {
            v_k += i32(1);
          }
        }
      }
    }
    if (((v_choice >= 0i) && (v_choice < 3i))) {
      var v_upgrade: i32 = (((i32(b_S[10i]) * 3i) + v_choice) % 6i);
      if ((v_upgrade == 0i)) {
        b_S[32i] = (b_S[32i] * 1.22f);
      }
      if ((v_upgrade == 1i)) {
        b_S[33i] = min(2.7f, (b_S[33i] * 1.17f));
      }
      if ((v_upgrade == 2i)) {
        b_S[5i] = (b_S[5i] + 25.0f);
        let cw_argument_index_6 = 5i;
        b_S[4i] = min(b_S[cw_argument_index_6], (b_S[4i] + 55.0f));
      }
      if ((v_upgrade == 3i)) {
        b_S[35i] = min(5.0f, (b_S[35i] + 1.0f));
        b_S[32i] = (b_S[32i] * 0.94f);
      }
      if ((v_upgrade == 4i)) {
        b_S[37i] = min(5.0f, (b_S[37i] + 1.0f));
        b_S[36i] = (b_S[36i] + 25.0f);
      }
      if ((v_upgrade == 5i)) {
        b_S[34i] = min(1.55f, (b_S[34i] * 1.08f));
        b_S[20i] = 0.0f;
        let cw_argument_index_7 = 5i;
        b_S[4i] = min(b_S[cw_argument_index_7], (b_S[4i] + 25.0f));
      }
      b_S[8i] = 1.0f;
    }
    return;
  }
  if ((v_mode != 1i)) {
    return;
  }
  b_S[61i] = 1.0f;
  var v_damage: f32 = 0.0f;
  var v_nearest: f32 = 100000.0f;
  var v_nx: f32 = 1.0f;
  var v_ny: f32 = 0.0f;
  var v_alive: i32 = 0i;
  {
    var v_j: i32 = 0i;
    loop {
      if (!(v_j < 320i)) { break; }
      var v_b: i32 = (v_j * 48i);
      if ((b_E[(v_b + 4i)] > 0.0f)) {
        v_alive += i32(1);
        var v_dx: f32 = (b_E[v_b] - b_S[0i]);
        var v_dy: f32 = (b_E[(v_b + 1i)] - b_S[1i]);
        var v_dd: f32 = ((v_dx * v_dx) + (v_dy * v_dy));
        if ((v_dd < v_nearest)) {
          v_nearest = v_dd;
          v_nx = v_dx;
          v_ny = v_dy;
        }
      }
      v_damage = (v_damage + b_E[(v_b + 20i)]);
      b_S[9i] = (b_S[9i] + b_E[(v_b + 21i)]);
      if ((b_E[(v_b + 21i)] > 0.0f)) {
        b_S[55i] = (b_S[55i] + 1.0f);
      }
      if ((b_E[(v_b + 19i)] > 0.0f)) {
        b_S[12i] = (b_S[12i] + 1.0f);
        b_S[39i] = (b_S[39i] + 1.0f);
        b_S[40i] = 2.5f;
        var v_gb: i32 = (i32(b_E[(v_b + 13i)]) * 16i);
        let cw_argument_index_8 = (v_b + 23i);
        let cw_argument_index_9 = (v_b + 22i);
        let cw_argument_index_10 = (v_b + 7i);
        var v_fit: f32 = (((min(b_E[cw_argument_index_8], 30.0f) * 0.07f) + (min(b_E[cw_argument_index_9], 12.0f) * 0.07f)) + (min(b_E[cw_argument_index_10], 25.0f) * 0.012f));
        if ((b_E[(v_b + 24i)] == b_G[(v_gb + 8i)])) {
          let cw_argument_index_11 = (v_gb + 6i);
          b_G[(v_gb + 6i)] = f_mixf(b_G[cw_argument_index_11], v_fit, 0.18f, cw_thread, cw_block, cw_grid);
          b_G[(v_gb + 7i)] = (b_G[(v_gb + 7i)] + 1.0f);
          var v_cause: i32 = i32(b_E[(v_b + 46i)]);
          if (((v_cause >= 1i) && (v_cause <= 4i))) {
            b_G[((v_gb + 9i) + v_cause)] = (b_G[((v_gb + 9i) + v_cause)] + 1.0f);
          }
        }
      }
      continuing {
        v_j += i32(1);
      }
    }
  }
  b_S[27i] = f32(v_alive);
  if ((((v_damage > 0.0f) && (b_S[38i] <= 0.0f)) && (b_S[14i] <= 0.0f))) {
    let cw_argument_index_12 = 4i;
    var v_accepted: f32 = min(min(22.0f, v_damage), b_S[cw_argument_index_12]);
    b_S[4i] = (b_S[4i] - v_accepted);
    b_S[38i] = 0.55f;
    b_S[54i] = (b_S[54i] + 1.0f);
    {
      var v_j: i32 = 0i;
      loop {
        if (!(v_j < 320i)) { break; }
        if ((b_E[((v_j * 48i) + 20i)] > 0.0f)) {
          b_E[((v_j * 48i) + 23i)] = (b_E[((v_j * 48i) + 23i)] + cw_divide_f32((v_accepted * b_E[((v_j * 48i) + 20i)]), v_damage));
        }
        continuing {
          v_j += i32(1);
        }
      }
    }
  }
  if ((b_S[4i] <= 0.0f)) {
    b_S[4i] = 0.0f;
    b_S[8i] = 4.0f;
    b_S[58i] = (b_S[58i] + 1.0f);
    return;
  }
  if ((b_S[6i] >= 600.0f)) {
    b_S[8i] = 5.0f;
    return;
  }
  if ((b_S[9i] >= b_S[11i])) {
    b_S[9i] = (b_S[9i] - b_S[11i]);
    b_S[10i] = (b_S[10i] + 1.0f);
    b_S[11i] = (14.0f + (b_S[10i] * 9.0f));
    b_S[8i] = 3.0f;
    b_S[56i] = (b_S[56i] + 1.0f);
    return;
  }
  b_S[51i] = 1.0f;
  b_S[7i] = (b_S[7i] + 1.0f);
  b_S[6i] = (b_S[6i] + cw_params.p_dt);
  b_S[50i] = (floor(cw_divide_f32(b_S[6i], 30.0f)) + 1.0f);
  b_S[13i] = max(0.0f, (b_S[13i] - cw_params.p_dt));
  b_S[14i] = max(0.0f, (b_S[14i] - cw_params.p_dt));
  b_S[15i] = max(0.0f, (b_S[15i] - cw_params.p_dt));
  b_S[17i] = max(0.0f, (b_S[17i] - cw_params.p_dt));
  b_S[18i] = max(0.0f, (b_S[18i] - cw_params.p_dt));
  b_S[20i] = max(0.0f, (b_S[20i] - cw_params.p_dt));
  b_S[21i] = max(0.0f, (b_S[21i] - cw_params.p_dt));
  b_S[38i] = max(0.0f, (b_S[38i] - cw_params.p_dt));
  b_S[40i] = max(0.0f, (b_S[40i] - cw_params.p_dt));
  if ((b_S[40i] <= 0.0f)) {
    b_S[39i] = 0.0f;
  }
  var v_mx: f32 = b_I[0i];
  var v_my: f32 = b_I[1i];
  var v_ml: f32 = f_len2(v_mx, v_my, cw_thread, cw_block, cw_grid);
  if ((v_ml > 1.0f)) {
    v_mx = cw_divide_f32(v_mx, v_ml);
    v_my = cw_divide_f32(v_my, v_ml);
  }
  var v_ax: f32 = ((((b_I[2i] * cw_params.p_aspect) * 350.0f) + b_S[25i]) - b_S[0i]);
  var v_ay: f32 = (((b_I[3i] * 350.0f) + b_S[26i]) - b_S[1i]);
  if ((((b_I[4i] < 0.5f) && (b_I[15i] > 0.5f)) && (v_alive > 0i))) {
    v_ax = v_nx;
    v_ay = v_ny;
  }
  var v_al: f32 = max(0.01f, f_len2(v_ax, v_ay, cw_thread, cw_block, cw_grid));
  b_S[23i] = cw_divide_f32(v_ax, v_al);
  b_S[24i] = cw_divide_f32(v_ay, v_al);
  if (((b_I[6i] > 0.5f) && (b_S[13i] <= 0.0f))) {
    b_S[14i] = 0.18f;
    b_S[13i] = 2.1f;
    b_S[57i] = (b_S[57i] + 1.0f);
    var cw_tmp_13: f32;
    if ((v_ml < 0.1f)) {
      cw_tmp_13 = b_S[23i];
    } else {
      cw_tmp_13 = v_mx;
    }
    b_S[59i] = cw_tmp_13;
    var cw_tmp_14: f32;
    if ((v_ml < 0.1f)) {
      cw_tmp_14 = b_S[24i];
    } else {
      cw_tmp_14 = v_my;
    }
    b_S[60i] = cw_tmp_14;
  }
  if ((b_S[14i] > 0.0f)) {
    v_mx = b_S[59i];
    v_my = b_S[60i];
  }
  var v_speed: f32 = (158.0f * b_S[34i]);
  if ((b_S[14i] > 0.0f)) {
    v_speed = (v_speed * 3.7f);
  }
  b_S[2i] = (v_mx * v_speed);
  b_S[3i] = (v_my * v_speed);
  var v_oldX: f32 = b_S[0i];
  var v_oldY: f32 = b_S[1i];
  var v_px: f32 = (b_S[0i] + (b_S[2i] * cw_params.p_dt));
  var v_py: f32 = (b_S[1i] + (b_S[3i] * cw_params.p_dt));
  let cw_argument_index_15 = 1i;
  if ((f_obstacle(v_px, b_S[cw_argument_index_15], cw_thread, cw_block, cw_grid) > 10.0f)) {
    b_S[0i] = v_px;
  }
  let cw_argument_index_16 = 0i;
  if ((f_obstacle(b_S[cw_argument_index_16], v_py, cw_thread, cw_block, cw_grid) > 10.0f)) {
    b_S[1i] = v_py;
  }
  let cw_argument_index_17 = 0i;
  b_S[0i] = max((-1600.0f), min(1600.0f, b_S[cw_argument_index_17]));
  let cw_argument_index_18 = 1i;
  b_S[1i] = max((-1600.0f), min(1600.0f, b_S[cw_argument_index_18]));
  b_S[2i] = cw_divide_f32((b_S[0i] - v_oldX), cw_params.p_dt);
  b_S[3i] = cw_divide_f32((b_S[1i] - v_oldY), cw_params.p_dt);
  let cw_argument_index_19 = 25i;
  let cw_argument_index_20 = 0i;
  b_S[25i] = f_mixf(b_S[cw_argument_index_19], b_S[cw_argument_index_20], (1.0f - exp(((-cw_params.p_dt) * 9.0f))), cw_thread, cw_block, cw_grid);
  let cw_argument_index_21 = 26i;
  let cw_argument_index_22 = 1i;
  b_S[26i] = f_mixf(b_S[cw_argument_index_21], b_S[cw_argument_index_22], (1.0f - exp(((-cw_params.p_dt) * 9.0f))), cw_thread, cw_block, cw_grid);
  if (((((b_I[4i] > 0.5f) || (b_S[31i] > 0.5f)) && (b_S[15i] <= 0.0f)) && ((v_alive > 0i) || (b_I[4i] > 0.5f)))) {
    b_S[15i] = cw_divide_f32(0.28f, b_S[33i]);
    b_S[16i] = (b_S[16i] + 1.0f);
    b_S[44i] = 1.0f;
    b_S[52i] = (b_S[52i] + 1.0f);
  }
  if (((b_I[5i] > 0.5f) && (b_S[17i] <= 0.0f))) {
    b_S[17i] = 0.95f;
    b_S[18i] = 0.24f;
    b_S[19i] = (b_S[19i] + 1.0f);
    b_S[53i] = (b_S[53i] + 1.0f);
  }
  if (((b_I[7i] > 0.5f) && (b_S[20i] <= 0.0f))) {
    b_S[20i] = 7.0f;
    b_S[21i] = 0.55f;
    b_S[22i] = (b_S[22i] + 1.0f);
  }
  if (((i32(b_S[7i]) % 18i) == 0i)) {
    var v_wanted: i32 = (18i + i32((b_S[6i] * 0.28f)));
    var cw_tmp_23: i32;
    if ((v_wanted > 230i)) {
      cw_tmp_23 = 230i;
    } else {
      cw_tmp_23 = v_wanted;
    }
    v_wanted = cw_tmp_23;
    if ((v_alive < v_wanted)) {
      b_S[29i] = b_S[28i];
      b_S[30i] = min(5.0f, f32((v_wanted - v_alive)));
      b_S[28i] = (b_S[28i] + b_S[30i]);
    }
  }
}
