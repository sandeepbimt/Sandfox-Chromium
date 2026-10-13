# SANDFOX Current State — 2026-10-13

## Mission and operating rules

SANDFOX goal: produce a working Android APK, then prove runtime behavior and advance features. DIRTFT: UNDERSTAND → MINIMAL CHANGE → TEST → LEARN → PRESERVE → PROCEED.

- One failure → inspect real logs → root cause → smallest justified fix → one validation.
- No speculative commits, trigger-only commits, overlapping CI runs, or repeated experiments without new evidence.
- Never confuse an experiment's timeout with a platform limit.
- Record unknowns explicitly. Never say a run/log/artifact was checked unless it actually was.

## Build route — critical continuity rule

**The currently investigated primary route is the CircleCI job defined on branch `sandfox/circleci-aerium-resume` in `sandeepbimt/Sandfox-Chromium`.** It combines:

- CircleCI execution and cache persistence (Aerium-style checkpoint of `out/afterbird_production`)
- pinned Chromium tag `151.0.7922.38`
- pinned Afterbird delta `5ff224f9ef8f8a0792abd2babc9f7164e8dcdb3e`
- Siso + BuildBuddy remote execution
- target `chrome_public_apk`

These are components of this same CircleCI route, not mutually exclusive alternatives. The separate GitHub Actions checkpoint-integrity experiments are a separate diagnostic route and must not silently replace this primary route.

Config: https://github.com/sandeepbimt/Sandfox-Chromium/blob/sandfox/circleci-aerium-resume/.circleci/config.yml
Pipeline script: https://github.com/sandeepbimt/Sandfox-Chromium/blob/sandfox/circleci-aerium-resume/ci/chromium_android_pipeline.sh

## 36-minute timeout — preserve original purpose

The CircleCI config runs `timeout --signal=INT --kill-after=30s 36m ... autoninja ... chrome_public_apk`, records the build exit code, then allows cache saving and diagnostic artifact collection before the job reports the original build result. The 36 minutes is an intentionally bounded diagnostic build window to preserve progress/evidence; it is not CircleCI's overall one-hour limit and must not be described as a platform limit. Do not blindly remove it or re-run the same experiment. First establish its actual result from existing CircleCI logs/artifacts.

## Verified facts from current read-only inspection

- Branch `sandfox/circleci-aerium-resume` exists.
- Its `.circleci/config.yml` contains the route described above.
- It restores cache with prefix `sandfox-aerium-v1-{{ .Branch }}-` and saves per-build output under `sandfox-aerium-v1-{{ .Branch }}-{{ .BuildNum }}`.
- The build step deliberately records status without failing immediately so later cache-save and diagnostics steps can run.
- Diagnostics copy `siso_failed_commands.sh`, tail `siso.INFO`, inventory `siso_output`, and store artifacts including `sandfox-remote-build.log` and any produced APK.
- Current inspection did not access live CircleCI run history/logs. Therefore, no claim is made here about the latest CircleCI run's final outcome, current cache key, remote/cache execution counts, or whether an APK artifact exists.

## Historical evidence (must be reverified against live run before decisions)

Earlier project notes report CircleCI run #112 saved an approximately 1.2 GiB checkpoint and a later run restored approximately 1.3 GiB in 26.86 seconds with identity validation passing. This establishes checkpoint transfer/restoration only; it does not prove Siso reuse or that the APK target can finish in the available window. Another earlier note says run #105 (commit `bbe789d`) reached actual compilation. Treat these as historical notes until matched to current run logs/artifacts.

## Separate GitHub Actions diagnostic route — do not conflate

Repository: `sandeepbimt/Sandfox-Chromium`.

- Run [38063947630](https://github.com/sandeepbimt/Sandfox-Chromium/actions/runs/38063947630): job “Create bounded GN/Siso checkpoint” succeeded; job “Restore on fresh runner and validate incremental target” failed at `autoninja -C "${OUT}" -t query "${TARGET}"` with `unknown tool "query"`.
- That failure is a bad diagnostic command, not proof that checkpoint restore itself failed. It exited before the actual incremental compile, so it did not prove resumed compilation.
- Follow-up commits added APK dry-run plan inspection, including commit [6c7b196](https://github.com/sandeepbimt/Sandfox-Chromium/commit/6c7b196425d4b4d87e0d17382a3e7d19ca766b8a) to run from Chromium source directory. Latest dry-run success is not verified.
- A manual full-build workflow exists at `.github/workflows/sandfox_overnight_apk_build.yml`, but a successful run/APK from it is not verified.
- Do not launch further GitHub Actions diagnostics merely to compensate for missing CircleCI continuity.

## Current blocker

**Unknown:** whether the latest CircleCI restored output checkpoint produces meaningful Siso action reuse and enough completed work to yield `ChromePublic.apk` within the bounded build window.

Not established: latest CircleCI run ID/status, exact `remote`/`cache`/`local` counts, time distribution, whether timeout signal is handled cleanly, whether checkpoint was saved after the build, or whether an APK artifact exists.

## Single next action

Read the latest relevant CircleCI run and its already-produced artifacts/logs—especially `sandfox-remote-build.log`, `siso.INFO.tail.txt`, `siso_failed_commands.sh`, checkpoint/cache-save step result, and artifact inventory. Do not start a new run or commit first.

From those existing logs answer only:
1. Did the 36-minute build window end by success, timeout (124/130/137), or compile/configuration error?
2. How many actions were `remote`, `cache`, `local`, `skip` at the end, and did those counts increase meaningfully during the run?
3. Was a new checkpoint saved after the attempt, and was `ChromePublic.apk` produced?
4. What exact one change, if any, follows from this evidence?

If the run already answers these questions, do not repeat it. If the required CircleCI data is not accessible from the available connection, ask the user for the CircleCI run URL or artifact files rather than substituting GitHub Actions evidence.

## Required response discipline in future chats

Before any proposal: read this file, inspect latest CircleCI evidence, distinguish verified facts from historical notes, and state the one next evidence-backed action. Never make the user restate the CircleCI/Aerium route. Never claim APK success without a real APK artifact and successful build result.
