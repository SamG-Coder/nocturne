# Validation performed for this build

## Boundaries

The browser in the build environment returned `ERR_BLOCKED_BY_ADMINISTRATOR` when asked to navigate to the local application. Consequently, **no end-to-end browser run, real-GPU WGSL validation, physical-GPU frame-rate measurement or human playtest was completed here**. No browser/GPU performance numbers are claimed.

The tests below are real but do not replace that missing device validation. `tests/browser.html` is supplied to execute the real-WebGPU checks locally. The game does not silently substitute a CPU, mocked learning model or JavaScript renderer.

## CUDA translation and host contract

`npm test` completed with three passing test cases:

1. All **17 entry points** compile through the vendored CUDA WebShader compiler. Generated WGSL and metadata agree exactly with the maintained split CUDA sources. Each uses no more than eight storage bindings and remains within the configured baseline uniform limits.
2. The actual host binds its resources against the actual runtime API, records frames, presents with aligned image rows, resizes, snapshots/restores weights and rejects malformed imports transactionally. **This is an API-contract test with a labelled mock device, not shader execution.**
3. The game host presents a compute-produced image and does not create a JavaScript scene or authored render pipeline.

The combined `Nocturne.cu` was also translated successfully with each of its 17 entry-point selections. The shipped runtime normally uses the split-source artifacts to avoid unrelated constants and helpers in each module. Compiler ASTs are omitted from shipped JSON artifacts; runtime WGSL and metadata are retained unchanged.

## Native CPU execution of the exact CUDA functions

Built with `g++ -x c++ -std=c++17 -O2 -fopenmp`. The harness supplies CUDA index/vector shims and calls the **same source functions** included from `kernels/`; it does not reimplement the game in a reference language. It is CPU validation, not an NVCC/CUDA GPU run.

Passed checks cover initialization, start/restart, movement, pausing/resuming, scythe damage, death/kill accounting, soul collection, relic upgrades, single-consumption of combat feedback across menu transitions, health loss, actual accepted-damage credit, player death, optimizer updates, changed weights, mature future targets, finite state/moments, learning freeze while gameplay continues, lineage replacement and finite bounded audio samples.

### Numerical derivative check

All **610 parameter derivatives** were compared with central finite differences on a small fixed batch with nonzero weights, away from the clipping boundary. Maximum absolute gradient error was approximately **4.8622 × 10^-6**, below the test tolerance of 2 × 10^-4. This checks the implemented backpropagation at that fixture; it is not a proof for every floating-point input or GPU backend.

### One scripted learning run

The harness supplies turning movement and attack inputs for approximately one simulated minute. Test health is raised to keep the fixture running; this is not a feature enabled in the game. Relic selections are automated by the fixture. The final observed statistics were:

| Metric | Value |
|---|---:|
| Optimizer steps | 279 |
| Mature future observations, including the following freeze interval | 613 |
| Neural prequential squared-displacement error EMA | 0.00328659 |
| Velocity-baseline error EMA | 0.00635299 |
| Final learned-policy influence | 0.367102 |
| Scripted ticks with influence above 0.01 | 2,850 of 3,600 |
| Maximum permitted/observed influence | 0.75 |

Errors sum the squared normalized x/y displacement errors; displacement is divided by 140 world units. These are recent EMAs, not full-run averages or calibrated probabilities. The values show that this fixture exercised a genuinely learned correction and its gate. They do **not** demonstrate universal improvement, difficulty balance, transfer to different players, or anything about human cognition.

The lineage-replacement assertion supplies deterministic fitness observations to exercise selection. It demonstrates that mutation/selection executes, not that every mutated population is objectively better. Per-run outcomes will vary with player behaviour, numerical backend and play duration.

## Rendered previews

`game.webp`, `title.webp` and `relics.webp` were rendered by the exact `buildTiles`, `renderWorld` and `renderUI` CUDA functions through the CPU harness. They are **not browser screenshots or performance captures**. The gameplay frame uses a deterministic test state and adjusted display health; menus are selected directly for visual inspection.

## Remaining validation

Run the supplied browser test on the intended GPU, then play full nights with different movement styles. Check long-run resource use, driver/browser compatibility, local storage behaviour and whether the adaptation is enjoyable. The intended result is measured, bounded tactical learning—not a promise that the game gets stronger on every update.
