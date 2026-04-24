# Runtime Parity Adapters

BA-kit parity execution is opt-in because it may call external LLM runtimes.

## Commands

Structure only:

```bash
bash scripts/test-runtime-parity.sh --check-structure
```

Run all available adapters:

```bash
bash scripts/test-runtime-parity.sh --run-adapters
```

Run one fixture on one runtime:

```bash
bash scripts/test-runtime-parity.sh --run-adapters --runtime claude f01
bash scripts/test-runtime-parity.sh --run-adapters --runtime codex f01
bash scripts/test-runtime-parity.sh --run-adapters --runtime antigravity f01
```

## Runtime Strategy

| Runtime | Adapter Mode | Command |
| --- | --- | --- |
| Claude Code | Headless | `claude -p` with read-only tool set |
| Codex | Headless | `codex exec` with read-only sandbox |
| Antigravity | Manual certification | JSON files under `tests/runtime-parity/certifications/antigravity/` |

## Antigravity Manual Certification

Antigravity local CLI exposes `antigravity chat`, but no deterministic stdout/JSON mode is
available from `antigravity chat --help`.

For each fixture:

1. Run the fixture manually in Antigravity.
2. Normalize the result into the matching golden `Behavior Envelope` fields.
3. Save `tests/runtime-parity/certifications/antigravity/fXX.json`.
4. Run `bash scripts/test-runtime-parity.sh --run-adapters --runtime antigravity fXX`.

Manual certification values must be strings.
