# SANDFOX — Chromium Architecture Charter

## Purpose

SANDFOX is being established as a future-ready Android browser built on
upstream Chromium, using a small, maintainable project delta rather than
tracking a complete Chromium source tree.

The immediate baseline is the existing Afterbird M151 architecture because it
has already demonstrated the key technical property SANDFOX needs: Chromium
source remains external and the repository carries only the browser-specific
delta, build control, tests, and documentation.

## Current baseline

- Chromium: `151.0.7922.38`
- Chromium source: external checkout, not vendored in this repository
- Android target: ARM64
- Chromium mode: `is_desktop_android=true`
- Current proven extension direction: upstream Chromium extension stack with
  the five M151 compatibility patches in `patches/m151/`
- uBlock Origin: pinned package is fetched and verified by the existing
  lockfile/fetch mechanism
- Current repository starting point:
  `5ff224f9ef8f8a0792abd2babc9f7164e8dcdb3e`

No Chromium version bump is part of this bootstrap.

## SANDFOX ownership model

The repository will own:

1. SANDFOX branding and Android UI changes.
2. SANDFOX-specific browser features.
3. Chromium compatibility patches that are genuinely required for SANDFOX.
4. Build configuration and reproducible build automation.
5. Extension/uBlock integration and validation.
6. Dark-page technology and per-site controls.
7. PWA behavior and custom PWA icon handling.
8. Performance instrumentation and regression tests.
9. Privacy/telemetry policy and related controls.
10. Architecture, specifications, diagnostics, and project governance.

The repository will not copy the Chromium monorepo merely to make SANDFOX
self-contained.

## Upstream relationship

The intended maintenance direction is:

```
Upstream Chromium
      ↓
SANDFOX compatibility/privacy layer
      ↓
SANDFOX core features
      ↓
performance
      ↓
dark pages
      ↓
PWA
      ↓
Android UI / branding
```

The exact ordering is architectural guidance, not a requirement that every
feature be implemented in that sequence.

Chromium updates should be handled by:

1. changing the pinned Chromium version deliberately;
2. rebasing the SANDFOX patch set against that Chromium version;
3. classifying every carried patch as:
   - still required,
   - fixed upstream and removable, or
   - still needed but requiring a new implementation;
4. validating the resulting browser before accepting the new baseline.

Patches must not be carried forward blindly.

## Afterbird relationship

Afterbird is the immediate ancestral/reference implementation for this
Chromium architecture.

SANDFOX may reuse proven Afterbird mechanisms where technically justified, but
Afterbird must not become a permanent runtime or build-time dependency.

Historical Afterbird/Kiwi material is evidence and provenance. It is not by
itself a requirement for SANDFOX.

## First-phase constraints

Until the Chromium baseline is independently proven under SANDFOX:

- do not change the Chromium pin;
- do not replace the five M151 patches;
- do not redesign the build pipeline;
- do not introduce a second browser engine;
- do not change the application package identifier;
- do not delete diagnostic/test infrastructure merely because it is named
  Afterbird/Kiwi;
- do not perform a full Chromium build solely to validate documentation or
  identity changes.

Functional changes must be introduced separately from this bootstrap.

## Branding policy

SANDFOX branding will be migrated deliberately.

The first bootstrap does not rename the Android package identifier. Package
identity affects installation, upgrades, storage, intents, PWA relationships,
and other runtime behavior and therefore requires its own controlled change
and validation.

Likewise, inherited license/provenance notices must be reviewed before being
rewritten. SANDFOX must preserve applicable Chromium, Kiwi/Afterbird, and
third-party notices rather than replacing them with a generic project notice.

## Success criterion for this phase

This phase is successful when SANDFOX has a clear, reviewable project boundary
while the proven Chromium/M151 build architecture remains unchanged.

The next functional milestone is not a large feature batch. It is to establish
a SANDFOX-controlled build/branding baseline, validate it with the cheapest
useful checks, and only then proceed to the first functional SANDFOX feature.
