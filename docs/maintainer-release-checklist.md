# Maintainer Release Checklist

Use this checklist before marking adaptive runtime memory work as release-ready.

## Contract And Runtime Distribution

| Check | Status | Evidence |
| --- | --- | --- |
| Contract sync validation | PASS | `bash scripts/test-contract-sync.sh` |
| Token budget validation | PASS | `bash scripts/check-token-budget.sh` |
| Claude installer syntax | PASS | `bash -n install.sh` |
| Codex installer syntax | PASS | `bash -n scripts/install-codex-ba-kit.sh` |
| Antigravity installer syntax | PASS | `bash -n scripts/install-antigravity-ba-kit.sh` |
| Shared CLI syntax | PASS | `bash -n scripts/ba-kit` |
| Codex generated asset check | PASS | covered by `scripts/test-contract-sync.sh` |
| Activation threshold validation | PASS | `bash scripts/test-activation-thresholds.sh` |
| Runtime install smoke | PASS | `bash scripts/test-runtime-install-smoke.sh` |

## Parity Harness

| Check | Status | Evidence |
| --- | --- | --- |
| Fixture/golden structure | PASS | `bash scripts/test-runtime-parity.sh --check-structure` |
| Normalized behavior envelopes | PASS | `tests/runtime-parity/goldens/*.md` f01-f12 |
| Runtime adapter execution | EXEMPT | v1 maintainer decision; adapters remain available for future release evidence |
| Claude Code headless adapter | EXEMPT | `bash scripts/test-runtime-parity.sh --run-adapters --runtime claude fXX` remains available |
| Codex headless adapter | EXEMPT | `bash scripts/test-runtime-parity.sh --run-adapters --runtime codex fXX` remains available |
| Antigravity manual adapter | EXEMPT | manual JSON certification remains available under `tests/runtime-parity/certifications/antigravity/` |
| Antigravity CLI capability scout | PASS | `docs/runtime-antigravity-capability-spike.md` records local `antigravity chat --help` constraints |

## Upgrade And Rollback

| Check | Status | Evidence |
| --- | --- | --- |
| Summary-only compact fallback fixture | COVERED | F01 |
| Missing index compact fallback fixture | COVERED | F05 |
| Activation freeze fixture | COVERED | F09 |
| Explicit-step fallback fixture | COVERED | F10 |
| Packet-disable fallback | OPERATIONAL CONTROL | disable runtime-specific packet enforcement until adapter parity exists |
| Installer-freeze fallback | OPERATIONAL CONTROL | do not publish installer rollout if this checklist has blocking FAIL items |
| Installed-runtime upgrade path | PASS | `bash scripts/test-runtime-install-smoke.sh` installs all 3 runtimes into a temporary `HOME` and runs installed `ba-kit doctor` |

## Distribution Strategy

Current decision: maintain the three installers with strict validation.

Rationale:
- The installers have different runtime targets and side effects.
- `scripts/test-contract-sync.sh`, syntax checks, and `ba-kit doctor/update` provide practical drift detection today.
- Single-source installer generation is deferred until repeated drift appears in release maintenance.

## Phase Close Rule

Phase 4 is closed for v1 by maintainer decision:
- runtime adapter execution is `EXEMPT`
- Antigravity live spike is `EXEMPT`
- structural parity, fixture/golden, installer smoke, and threshold checks remain required

Future releases may reopen runtime execution as a blocking gate.
