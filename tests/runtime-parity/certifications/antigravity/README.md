# Antigravity Manual Runtime Certification

Antigravity currently exposes `antigravity chat`, but local CLI help does not expose a
headless stdout/JSON mode equivalent to `claude -p` or `codex exec`.

Until a deterministic adapter exists, certify each fixture manually:

1. Open Antigravity with BA-kit installed.
2. Submit the fixture Input Command from `tests/runtime-parity/fixtures/fXX-*.md`.
3. Normalize the result into a JSON object with the exact keys from the matching golden's
   `## Behavior Envelope`.
4. Save it as `tests/runtime-parity/certifications/antigravity/fXX.json`.
5. Run `bash scripts/test-runtime-parity.sh --run-adapters --runtime antigravity fXX`.

Manual certification JSON values must be strings.
