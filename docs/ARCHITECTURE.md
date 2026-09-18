# Execution architecture

The source of game behaviour is `kernels/*.cu`. The browser never computes enemy destinations, collisions, damage, fitness, gradients, neural predictions or game pixels.

## Frame contract

Input is a small float buffer. An active simulation advances in fixed 1/60-second steps. `stepWorld` decides whether a real simulation step occurred, using S[51], and separately acknowledges consumed enemy feedback with S[61]. This avoids double-counting kills at a relic menu or losing events when pausing.

For each step, ordered dispatches execute:

1. `stepWorld`: consume previous enemy feedback, credit actual health loss to the old enemy records, and update mode, player and attack intents.
2. `stepProjectiles`: update/create projectile states.
3. `stepEnemies`: read the old population and write the next population. Each thread owns one enemy's next-state record.
4. `evolvePopulation`: periodically replace eligible population variants.
5. `recordExperience`: every six active steps, record features and mature the target from five observations earlier.
6. `prepareBatch`, `forwardBatch`, `backwardBatch`, `computeGradient`, `updateWeights`: train every twelve active steps when enough observations exist and learning is enabled.
7. `inferPlayer`: compute the bounded, half-second displacement forecast. On observation steps, store that prediction for future scoring.

The enemy buffers swap roles. Rendering then dispatches `buildTiles`, `renderWorld` and `renderUI`. The last two kernels write packed RGBA8 values directly into the final pixel buffer. A WebGPU buffer-to-texture copy presents that image. Rows are rounded to a 256-byte-compatible stride. There is no authored vertex/fragment pipeline.

The host caps queued work and performs at most four fixed steps per display submission. A slow device therefore does not accumulate an unlimited queue. Physics time excludes paused frames, relic selection and title screens. Rendering animation has a separate clock.

## Neural model

Inputs are 16 floats. The hidden layer contains 32 tanh units. Two linear outputs predict corrections to a constant-velocity displacement estimate. The first-layer weights are small seeded values; output-layer weights and biases start at zero, so the untrained model starts at the baseline rather than an arbitrary destination.

Parameter layout:

- 0–511: hidden weights, [32,16].
- 512–543: hidden biases.
- 544–607: output weights, [2,32].
- 608–609: output biases.

The training prediction is `current_velocity * 0.5 / 140 + network_residual`. Targets are actual future displacement divided by 140, bounded componentwise to [-1.5, 1.5]. Policy-facing predictions and the evaluation baseline have the same bounds. The training loss is one half the sum of the two squared coordinate errors, averaged across the batch. Gradients are clipped componentwise to [-0.8,0.8]. AdamW uses learning rate 0.002, beta1 0.9, beta2 0.999, epsilon 0.00001 and decay 0.0001.

The replay has 4096 records. The five newest records do not yet have future targets and are never sampled. Half each minibatch samples the latest 64 mature records and half samples all currently valid history. The buffer and run-local counts reset together at a new run.

The policy gate uses exponentially weighted, prequential prediction errors, not the training loss. An observation's prediction is saved before its later target exists. The error is the sum of squared normalized x/y displacement errors. After the initial warm-up, the gate is:

```text
max(0, min(0.75, 1 - (neural_error + 0.002) / (velocity_error + 0.002)))
```

Enemies blend bounded velocity leading with that learned prediction. This is not a calibrated probability or a claim about human cognition. A positive gate is a recent, local predictive comparison, not a guarantee of future outperformance.

## Individual lives and population learning

There are 320 enemy slots and five species. The authored spawn target increases over a ten-minute run; not every slot is simultaneously occupied. Each individual owns a 48-float record. Living individuals use their birth-time six-trait snapshot rather than reading mutable population traits mid-life.

Each species has eight population variants. The six traits govern lead, flank magnitude, preferred distance/commitment range, caution, separation distance and attack commitment. Damage/pressure/survival outcomes update the variant that produced the individual, only if that slot still represents the same generation. This prevents an old creature's death from scoring a replacement genome it never used.

Selection evaluates variants with sufficient death observations, copies a better-scoring variant, adds bounded mutations and replaces one lower-scoring slot per species when eligible. Fitness caps damage at 30, nearby-pressure time at 12 seconds and survival contribution at 25 seconds. These caps reduce incentives for endless passive survival. They are authored design choices, not proof of fun or fairness.

A lineage generation number and parent slot are retained with the current variants. This is not a complete historical family tree. Per-weapon death counts provide inspection data; they are not a second neural model.

## Persistence and browser boundary

One queue-ordered GPU snapshot copies W, M, V, G and Brain into a single staging buffer, keeping the weights and optimizer from the same point in execution. Import validates every field before writing any buffer. Replay/run-local counts and the immediate prediction gate are reset during import. GPU memory is never mixed with partially validated external values.

JavaScript necessarily owns WebGPU device setup, browser events, the display loop, audio-buffer playback, file import/export and IndexedDB. CUDA generates the audio samples themselves. The DOM boot/error message is browser infrastructure; all in-game visual interfaces are CUDA-rendered.
