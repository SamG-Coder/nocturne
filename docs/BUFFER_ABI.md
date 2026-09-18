# Buffer ABI

All entries below are float32 except Tiles (int32) and Pixels (uint32). The compiler-generated metadata defines bindings per entry point. No buffer is bound twice through writable aliases.

| Buffer | Elements | Meaning |
|---|---:|---|
| S | 128 | World/player/mode/counters and feedback acknowledgements. |
| I | 32 | Browser input values. |
| E0, E1 | 320 × 48 each | Ping-pong individual enemy states. |
| P | 128 × 10 | Projectiles. |
| W, M, V | 610 each | Parameters and AdamW moments. |
| G | 5 × 8 × 16 | Current enemy-population variants and statistics. |
| Brain | 32 | Training/validation counters, predictor and lineage summaries. |
| R | 4096 × 28 | Experience ring. |
| Work | 32 × 88 | Batch activations and backpropagation workspace. |
| Grad | 610 | Reduced, clipped batch gradient. |
| Tiles | ceil(width/32) × ceil(height/32) × 128 | Bounded screen-space candidate lists. |
| Pixels | width × height | Completed image, little-endian RGBA8. |

## S

0–3: position x/y and measured velocity x/y. 4/5: health/max health. 6/7: active time/tick. 8: mode (0 title, 1 active, 2 pause, 3 relic, 4 dead, 5 dawn). 9–12: souls, level, next-level requirement, kills. 13–22: dash/fire/scythe/ward cooldowns, active durations and serials. 23/24: aim direction. 25/26: camera. 27: live count. 28–30: spawn sequence/start/quota. 31: autofire (off on desktop, on for coarse/touch pointers; T toggles). 32–37: damage, fire-rate multiplier, movement multiplier, pellet count, soul reach and blade count. 38–40: hurt invulnerability/combo. 44: fire intent this step. 45: learning enabled. 46: UI time. 47: field notes visible. 48: seed. 49: reset flag. 50: wave. 51: actual simulation-step flag. 52–58: audio event counters. 59/60: locked dash direction. 61: prior enemy feedback was consumed. 64 and 68–74: previous button values for CUDA edge detection. 76: autofire preference has been initialized from the host.

## I

0/1: movement axes. 2/3: normalized canvas cursor [-1,1]. 4/5: left/right buttons. 6: dash. 7: ward. 8: Enter. 9: Escape. 10: relic choice 1–3, zero otherwise. 11: autofire toggle. 12: restart. 13: learning toggle. 14: field-notes toggle. 15: coarse/touch pointer (auto-aim only when this is set). Browser presentation controls do not enter the game simulation.

## Enemy record

0–3: position/velocity. 4/5: health/max (0 unused; -1 corpse). 6: species. 7: age. 8/9: decision state/timer. 10: attack cooldown. 11: fear. 12: phase/side preference. 13: population variant slot. 14–16: last registered projectile/scythe/ward serial. 17: hit flash. 18: corpse age. 19–21: kill/player-damage/soul-pickup feedback. 22/23: accumulated nearby pressure/damage. 24: birth generation. 25/26: knockback. 27/28: attack direction. 29–33: independent ranged projectile. 34: wind-up/lunge duration. 35: elite. 36: spawn serial. 37: individual seed. 38: soul value. 40–45: inherited trait snapshot. 46: killing weapon (1 gun, 2 scythe, 3 ward, 4 blade).

Decision states: 0 hunt, 1 flank, 2 wait, 3 withdraw, 4 wind-up, 5 lunge. Separation/knockback can displace a waiting enemy.

## G record

0–5: six traits. 6: fitness EMA. 7: scored death count. 8: generation. 9: selected parent slot for a replacement. 10–13: deaths by gun/scythe/ward/blade in this current variant. Remaining fields are reserved.

## Brain

0: optimizer steps. 1: lifetime mature observations. 2/3: neural/baseline prequential error EMAs. 4: policy gate. 5: latest batch training loss. 7: valid mature records in the current run. 8/9: predicted normalized displacement. 10: current-run observation sequence. 11: lifetime observations. 12: selected population replacements. 13: maximum current generation seen.

## Replay and workspace

R[0..15]: features. 16/17: observation position. 18/19: matured target. 20/21: previously made prediction. 22/23: previously made baseline prediction. 24: mature flag. 25: active observation time. 26: measured prediction error.

Work[0..15]: input. 16/17: target. 18/19: prediction. 20..51: hidden activations. 52..83: hidden deltas. 84/85: output deltas. 86: sample loss.
