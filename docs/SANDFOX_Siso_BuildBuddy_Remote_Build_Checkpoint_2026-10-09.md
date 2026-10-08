# SANDFOX — Siso/BuildBuddy Remote Build Checkpoint

Date: 2026-10-09

## Proven

The following path has been experimentally verified:

Chromium M151 source
→ Siso 1.6.5
→ BuildBuddy REAPI (remote.buildbuddy.io:443)
→ remote executor
→ clang++
→ successful real Chromium C++ compilation

The decisive successful probe reported:

```
noexec:0 local:0 remote:1 cache:0 skip:0
Build Succeeded: 1 steps
=== SANDFOX REAL CHROMIUM REMOTE COMPILE CONFIRMED ===
```

The compile action used a real Chromium M151 header:
`base/compiler_specific.h`, with its required build headers.

## Permanent lessons

1. BuildBuddy Remote Runner is only the coordinator/runner environment; it is not the Chromium build machine.
2. Siso REAPI remote execution is real and working.
3. `--strict_remote` was essential for proving remote execution without local fallback.
4. Do not checkout a full Chromium tree before sparse-checkout; that defeated the first sparse probe.
5. Do not infer REAPI failure from `reapi ops err` alone; verify Siso's execution counters.
6. Do not modify the clean SANDFOX build baseline merely to test remote execution.

## Existing SANDFOX build baseline

- Chromium: 151.0.7922.38
- Android: arm64
- Target: chrome_public_apk
- Existing pipeline: `ci/chromium_android_pipeline.sh`
- Existing GN variants: `.build/args/test.gn`, `.build/args/release.gn`
- Existing local C4 lesson: Chromium compilation can run locally on CircleCI large, but the 1-hour CircleCI ceiling stops the full build.
- Existing C4 build was local Siso execution (`remote:0`).

## Official Chromium integration point

Chromium's documented non-Google REAPI path uses:

- GN args: `use_remoteexec = true`, `use_siso = true`
- REAPI address/instance
- a Siso backend.star describing worker platform properties
- a credential helper
- `autoninja` as the normal build entry point

Therefore the next implementation should be **opt-in**, not baked into the normal test/release args.

## Next justified experiment

Create an opt-in SANDFOX BuildBuddy mode in the existing Chromium pipeline:

1. Preserve normal args unchanged.
2. When explicitly enabled, generate the existing args.gn and append:
   `use_remoteexec = true`
   `use_siso = true`
3. Provide:
   `SISO_REAPI_ADDRESS=remote.buildbuddy.io:443`
   `SISO_REAPI_INSTANCE=default`
   `SISO_CREDENTIAL_HELPER=<workspace helper>`
4. Provide a BuildBuddy-compatible Siso backend configuration.
5. Run a small real Chromium target first.
6. Inspect Siso counters and BuildBuddy invocation.
7. Only after that, attempt `chrome_public_apk`.

## Success criterion

For the small real Chromium target:

```
remote > 0
local == 0 for strict-remote probe actions
successful output produced
```

For the first real SANDFOX build:

- GN generation succeeds.
- meaningful Chromium actions execute remotely.
- no unexplained local fallback dominates the build.
- failure logs identify the exact failing action.
- CircleCI remains a coordinator/source workspace rather than the primary compiler.

## Do not do yet

- Do not change the default GN args to enable remote execution globally.
- Do not launch the full APK build.
- Do not add speculative BuildBuddy worker/container properties.
- Do not create another synthetic Siso probe; the real Chromium remote compile is already proven.

## Morning decision tree

A. Small real Chromium target remotely succeeds:
   → proceed to a controlled `chrome_public_apk` remote-build experiment.

B. REAPI connects but Chromium actions fail:
   → inspect the exact Siso/backend/platform error and make one minimal fix.

C. Remote execution works but throughput is poor:
   → measure executor concurrency, action queueing, CAS transfer, and CircleCI coordinator time before changing architecture.
