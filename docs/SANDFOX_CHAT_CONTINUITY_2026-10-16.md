# SANDFOX Chat Continuity — 16 October 2026

## Purpose and rules

Build SANDFOX as a future-ready Android browser:
1. Fast practical cold launch for browser, webpages and PWAs, including uBlock Origin.
2. Excellent dark-page rendering for CSS, images, SVG, video, canvas, code, iframes and dynamic pages; no double-darkening, per-site exceptions, high compatibility and low overhead.
3. First-class PWA installation, standalone behavior, navigation, reload/back/forward, cold/warm launch, process-death recovery and custom icon choice during creation.
4. Minimum unnecessary telemetry without sacrificing security, compatibility or stability.

**DIRTFT:** Understand → minimal change → test → learn → preserve → proceed.

For every failure, inspect the actual log, isolate the exact root cause, make one justified fix, run one validation, and inspect the result. Preserve working checkpoints. Avoid speculative commits, overlapping/expensive CI runs, broad cache purges, and repeat investigation of settled questions. Prefer offline validation. Do not claim success without the result and artifact evidence. Continue routine investigation independently instead of asking the user to direct every step.

## Proven APK build line — user-established facts

### Commit 1c3b248
- Commit: https://github.com/sandeepbimt/iceraven-browser/commit/1c3b2480677819025208d8d0db34826991e670ef
- CircleCI workflow: https://app.circleci.com/workflow/2ae43949-2d72-4c0b-8e90-d5de3f74d8bf
- This run successfully generated a working Chrome APK.
- Problem: all five stages performed expensive work.

### Commit 2b254b9
- Commit: https://github.com/sandeepbimt/iceraven-browser/commit/2b254b9fbe28b5b1a86aac2ee0fb2bd989cd619a
- CircleCI job: https://app.circleci.com/workflow/f454f0b2-e829-4f7c-9393-42b7833b497b/job/b34e0466-f208-4ff8-a3a1-2cb75fddd286
- The follow-up made later stages finish in seconds when a verified APK already exists, instead of repeating expensive work.
- The five stage jobs are marked successful in the GitHub status API.
- User confirms that a valid, working APK was found in both runs.

**Decision:** use this proven five-stage CircleCI line for SANDFOX UI work. Preserve its checkpoint identity, Siso state, APK verification, and fast-exit behavior. Do not build a separate full Chromium pipeline.

Another known-green staged run:
- Commit b5343ce604fabf2aeee99d9946ad0c472f6f0278, all five CircleCI stage statuses succeeded.
- https://github.com/sandeepbimt/iceraven-browser/commit/b5343ce604fabf2aeee99d9946ad0c472f6f0278

## Clean-base and architecture information

### Current Chromium/SANDFOX base
- Chromium pin: 151.0.7922.38.
- Browser base: Afterbird; the user liked the browser and its Chromium Android/desktop-Android extension stack.
- Overlay repository: sandeepbimt/Sandfox-Chromium.
- Overlay/UI branch: feature/quetta-ui-sandfox-branding.
- Proven pipeline repository: sandeepbimt/iceraven-browser.
- Pipeline branch: sandfox/checkpoint-stage-v1.
- Original Afterbird fork point previously recorded: 5ff224f9ef8f8a0792abd2babc9f7164e8dcdb3e.
- Later Afterbird baseline commit referenced in overlay history: abd6a734b60f6852019916c82682509f7bd6b4f8.
- The pipeline’s pinned overlay SHA must match all checkout and checkpoint-fingerprint locations. Changing it changes the build-input fingerprint; never assume cached outputs still match without checking.

### Historical clean bases — not the current Chromium base
- Earlier Gecko/Iceraven experiments: CI65 was once the PWA clean base; CI74 later became the clean base with user-script typography; CI166 was later declared the working clean base.
- CI166 was reported with per-site PWA creation, custom PWA icons during creation, universal typography, uBlock + Brave engine (then considered fastest), PWA back-to-page-1/home navigation fix, and no blank page during PWA open/close.
- The project later shifted current browser work to Chromium/Afterbird because full Gecko builds were too costly in the available CI setup. These historical CI65/CI74/CI166 results are not proof that those features exist in the current Chromium APK.
- Constraints: GitHub Free resources are limited; do not assume GitHub Actions can build Chromium end-to-end. CircleCI stage/runtime budgets, dependency fetch bandwidth, RAM/disk, cache, and Siso remote execution are limited. User has been frustrated by wasted CI credits and repeated exploratory runs.

## Complete UI scope requested

User explicitly asked for all SANDFOX UI changes together, in one properly prepared CI run:
1. Default fresh profiles to a bottom address bar while preserving an explicit user-selected top position.
2. Enable Chromium's native Android bottom navigation bar.
3. Provide Home, New Tab, tab switcher and app-menu access; retain bottom bar on the New Tab Page.
4. Enable Chromium's grouped/Quetta-inspired three-dot menu behavior.
5. Provide menu quick actions for Back, Forward, Bookmark, Download and Reload.
6. Improve visual consistency, spacing, and dark-theme behavior using Chromium components where feasible.
7. Include the user's approved SANDFOX fox icon, combined logo, and wordmark in the branding pass without substituting or redesigning them.

Branding must preserve the exact fox silhouette/identity, proportions, silver/orange metallic finish and lettering. Original assets must stay unchanged until actual app resources are integrated and verified. Do not say the APK contains branding or a bespoke Quetta menu unless the pinned files and APK prove it.

## Overlay patches and prior failure lessons

Current overlay patch directory: patches/m151/.
- 0001-mv2-reenable.patch
- 0002-browseraction-schema-desktop-android.patch
- 0003-extensions-menu-null-coordinator-fallback.patch
- 0004-allow-unpacked-without-devmode.patch
- 0005-webstore-desktop-user-agent.patch
- 0006-siso-safe-crash-diagnostics-output.patch
- 0007-android-bottom-bar-quick-actions.patch
- 0008-quetta-menu-quick-actions.patch

The old 0004-default-bottom-toolbar.patch repeatedly failed in CircleCI at AddressBarPreference.java around line 53/54. Several hunk rewrites failed. Lesson: matching a public upstream Chromium file is not proof the patch applies to the actual checked-out tree after hooks and other patches.

That patch was removed and replaced by a guarded Python source edit in the CircleCI step named Apply pinned Afterbird delta. It expects exactly one occurrence of both source blocks before changing:
- Fresh default DEFAULT_POSITION_AND_SOURCE: TOP_SETTINGS to BOTTOM_SETTINGS.
- fromLocalState(...): use TOP_SETTINGS when local state explicitly indicates the toolbar is top.
It should print SANDFOX_BOTTOM_TOOLBAR_DEFAULT=PASS on success. If the exact source blocks differ, it deliberately fails loudly rather than make an uncertain edit.

Another distinct patch failure:
- CI reported “patch fragment without header at line 31: @@ -1597,6 +1597,6 @@” in 0007-android-bottom-bar-quick-actions.patch.
- Root cause: unprefixed blank lines between hunks inside the same unified diff; the same malformed separator was found in 0008-quetta-menu-quick-actions.patch.
- These separators were removed in the overlay. Latest pipeline-pinned overlay SHA is 882d5426fde4a6b469304df561b8d1ea89629cf3, commit message “fix: remove invalid blank separator from grouped menu patch”.
- Offline checks confirmed the fixed 0007/0008 hunk counts are internally consistent. This is not a substitute for running git apply in the real checkout.

Pipeline revisions:
- 35485d3d285c745801712acc876b050000907354: connected first overlay to proven five-stage line; failed at address-bar patch.
- 7c158e87b12fa8c9ef5c48c63b93f24c3cf016f2: corrected overlay pin; still failed at address-bar patch.
- 84bd2ebfa58403af87d7d5836d42991662706805: bundled bottom toolbar/menu UI; failed.
- 032203dece48c7e728c11e4883e2c35590549109: removed brittle 0004 patch and used guarded source edit; the run later failed during dependency sync before applying the overlay.
- a95be1d861a26645cc21d770d1acb427fe19bc1a: fixed malformed UI patch separators and retried full UI set; failed because patch 0007 was still malformed before its separator was corrected.
- 7cd5a293a4c4a8b31b6d98a9f57909f6abee8c25: added bounded retry for transient dependency-fetch HTTP 503 / packfile errors; current known pending build as described below.

## Latest dependency-sync failure — root cause supported by log

User uploaded build_204_step_110_container_0.txt (272 lines) from gclient sync -D --no-history --nohooks.
- It failed fetching third-party repository https://chromium.googlesource.com/external/github.com/google/gemmlowp.git/.
- Log lines 239–241: RPC failed with HTTP 503; fatal expected 'packfile'; fetch returned HTTP 503.
- It retried and moved conflicting directories, including gemmlowp into _bad_scm, then failed with exit status 128 for commit 16e8662c34917be0065110bfcd9cc27d30f52fdf.
- Other conflict warnings named arcore, breakpad, fast_float and libaddressinput while fetch retries were underway.
- Proven cause: dependency fetch endpoint returned transient/server HTTP 503; the conflicting-directory messages are associated with failed fetch/retry behavior. Nothing in this log makes the SANDFOX UI patches the cause.
- Do not blindly delete _bad_scm, wipe cache/source, revert UI patches, or invalidate checkpoints to address this remote fetch failure.

## Retry fix now committed in pipeline

Current branch config wraps dependency sync in a bounded retry:
- Captures gclient sync output to a log.
- Attempts at most 3 times.
- Retries only when output contains HTTP 503 / returned error 503 / expected packfile.
- Delays 15 seconds then 30 seconds.
- Nonmatching errors are not retried. After attempt 3 it gives a specific error.
This is a targeted response to observed logs, not proof that the remote server will recover.

## Current pipeline state at last check — refresh before claiming status

Newest known pipeline commit:
- 7cd5a293a4c4a8b31b6d98a9f57909f6abee8c25
- Message: ci: retry transient Chromium dependency fetch failures.
- Active Stage 1 job link: https://app.circleci.com/workflow/0e1aafbc-2648-4ffd-98d8-08eb34354b61/job/199cb3e6-d1c9-4ebe-8d2c-d3232e966f23
- Last remote status checked: pending.
- Job: c4-afterbird-stage-1.
- Current config blob SHA at last check: 23adcafbe8fd048974506da41b2b17ec17b2780f.
- Overlay pin in checkout/fingerprint references: 882d5426fde4a6b469304df561b8d1ea89629cf3.
- The current pending run must be allowed to complete; do not start another run or commit a second fix while it is active.
- No evidence yet that this latest Chromium UI run generated a valid APK.

## Next actions

1. Refresh the status/logs of the active Stage 1 run above before any write.
2. If running, leave it alone and inspect log progress where possible.
3. If it fails during dependency sync, determine whether all 3 targeted retries ran and what exact error remained. Make one justified change only; do not broad-purge.
4. If sync passes, ensure Apply pinned Afterbird delta succeeds, including the fixed 0007/0008 patches and SANDFOX_BOTTOM_TOOLBAR_DEFAULT=PASS.
5. Inspect checkpoint metadata and Siso metrics. Verify matching input fingerprint and that later stages reuse checkpoint/build state rather than rerun expensive setup.
6. Confirm the resulting APK file/artifact, checksum and package; then test install/launch and actual UI. Do not announce success without evidence.
7. Keep all requested UI scope together, but do not overstate the current feature patches as a fully bespoke Quetta UI or completed branding integration.
8. Record exact outcomes into the next continuity file so this debugging sequence is not repeated.

## Tooling notes

GitHub connector is available via functions.exec, including:
- mcp__GitHub__fetch_file({repository_full_name,path,ref})
- mcp__GitHub__fetch_commit({repo_full_name,commit_sha})
- mcp__GitHub__compare_commits({repo_full_name,base,head})
- mcp__GitHub__update_file(...)
- mcp__GitHub__delete_file(...)
- mcp__GitHub__create_file(...)
- mcp__GitHub__fetch({url})

Discover exact tool arguments through ALL_TOOLS if necessary. No reliable local shell is assumed. Never invent a commit SHA, run ID, link, log result, or build artifact.
