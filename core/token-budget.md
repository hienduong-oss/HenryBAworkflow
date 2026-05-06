# Token Budget Baseline

Mục tiêu của file này là khóa trần kích thước cho instruction surface của BA-kit sau refactor `contract + stub + step files`.

- Đơn vị dùng trong CI là `bytes`, không phải token.
- `bytes` được dùng vì ổn định hơn tokenization runtime và đủ tốt để bắt drift sớm.
- Các ngưỡng `max` không phải mục tiêu để lấp đầy; chúng chỉ là guardrail.
- Khi một thay đổi cố ý mở rộng instruction surface, cập nhật cả `baseline` lẫn `max` trong block JSON bên dưới, rồi chạy lại budget check.

## Baseline hiện tại

- Shared entry runtime (ba-start): `core/contract.yaml` + `core/contract-behavior.md` + `skills/ba-start/SKILL.md` = `29,490 bytes` (contract files grew since v1 capture)
- Presale entry runtime: `core/contract.yaml` + `core/contract-behavior.md` + `skills/ba-presale/SKILL.md` = `29,984 bytes`
- Runtime policies hiện tại: `CODEX.md` + `GEMINI.md` + `CLAUDE.md` = `7,152 bytes`
- Các path đắt nhất hiện tại:
  - `build_bundle` (presale) = `42,088 bytes`
  - `handoff_bundle` (presale) = `41,014 bytes`
  - `srs_wireframe_bundle` (ba-start) = `23,821 bytes`

## Guardrail source

```json
{
  "version": 2,
  "captured_at": "2026-05-05",
  "units": "bytes",
  "files": [
    { "path": "core/contract.yaml", "baseline": 10210, "max": 12500, "label": "machine contract" },
    { "path": "core/contract-behavior.md", "baseline": 16301, "max": 19500, "label": "behavior contract" },
    { "path": "skills/ba-start/SKILL.md", "baseline": 2779, "max": 3500, "label": "ba-start stub" },
    { "path": "skills/ba-presale/SKILL.md", "baseline": 3373, "max": 4200, "label": "ba-presale stub" },
    { "path": "skills/ba-presale/steps/bootstrap.md", "baseline": 6076, "max": 7500, "label": "presale bootstrap step" },
    { "path": "skills/ba-presale/steps/domain-study.md", "baseline": 3526, "max": 4500, "label": "presale domain-study step" },
    { "path": "skills/ba-presale/steps/clarify.md", "baseline": 8188, "max": 10000, "label": "presale clarify step" },
    { "path": "skills/ba-presale/steps/build.md", "baseline": 12577, "max": 15000, "label": "presale build step" },
    { "path": "skills/ba-presale/steps/handoff.md", "baseline": 11402, "max": 13700, "label": "presale handoff step" },
    { "path": "skills/ba-presale/steps/status.md", "baseline": 3009, "max": 3800, "label": "presale status step" },
    { "path": "skills/ba-start/steps/intake.md", "baseline": 3212, "max": 4000, "label": "intake step" },
    { "path": "skills/ba-start/steps/impact.md", "baseline": 2689, "max": 3300, "label": "impact step" },
    { "path": "skills/ba-start/steps/backbone.md", "baseline": 1225, "max": 1700, "label": "backbone step" },
    { "path": "skills/ba-start/steps/frd.md", "baseline": 1240, "max": 1700, "label": "frd step" },
    { "path": "skills/ba-start/steps/stories.md", "baseline": 1342, "max": 1800, "label": "stories step" },
    { "path": "skills/ba-start/steps/srs.md", "baseline": 1337, "max": 1800, "label": "srs router step" },
    { "path": "skills/ba-start/steps/srs-core.md", "baseline": 2770, "max": 3400, "label": "srs core step" },
    { "path": "skills/ba-start/steps/srs-wireframes.md", "baseline": 2986, "max": 3600, "label": "srs wireframes step" },
    { "path": "skills/ba-start/steps/srs-assembly.md", "baseline": 1848, "max": 2300, "label": "srs assembly step" },
    { "path": "skills/ba-start/steps/wireframes.md", "baseline": 4786, "max": 5600, "label": "wireframes step" },
    { "path": "skills/ba-start/steps/package.md", "baseline": 1809, "max": 2400, "label": "package step" },
    { "path": "skills/ba-start/steps/status.md", "baseline": 1585, "max": 2200, "label": "status step" },
    { "path": "CODEX.md", "baseline": 2888, "max": 3500, "label": "codex runtime policy" },
    { "path": "GEMINI.md", "baseline": 2504, "max": 3200, "label": "antigravity runtime policy" },
    { "path": "CLAUDE.md", "baseline": 1760, "max": 2500, "label": "claude runtime policy" }
  ],
  "bundles": [
    {
      "name": "runtime_policies",
      "baseline": 7152,
      "max": 8500,
      "paths": ["CODEX.md", "GEMINI.md", "CLAUDE.md"]
    },
    {
      "name": "shared_entry_runtime",
      "baseline": 29490,
      "max": 34000,
      "paths": ["core/contract.yaml", "core/contract-behavior.md", "skills/ba-start/SKILL.md"]
    },
    {
      "name": "presale_entry_runtime",
      "baseline": 29984,
      "max": 34500,
      "paths": ["core/contract.yaml", "core/contract-behavior.md", "skills/ba-presale/SKILL.md"]
    },
    {
      "name": "presale_bootstrap_bundle",
      "baseline": 36060,
      "max": 42000,
      "paths": ["core/contract.yaml", "core/contract-behavior.md", "skills/ba-presale/SKILL.md", "skills/ba-presale/steps/bootstrap.md"]
    },
    {
      "name": "presale_domain_study_bundle",
      "baseline": 33510,
      "max": 39000,
      "paths": ["core/contract.yaml", "core/contract-behavior.md", "skills/ba-presale/SKILL.md", "skills/ba-presale/steps/domain-study.md"]
    },
    {
      "name": "presale_clarify_bundle",
      "baseline": 38172,
      "max": 44500,
      "paths": ["core/contract.yaml", "core/contract-behavior.md", "skills/ba-presale/SKILL.md", "skills/ba-presale/steps/clarify.md"]
    },
    {
      "name": "presale_build_bundle",
      "baseline": 42561,
      "max": 49500,
      "paths": ["core/contract.yaml", "core/contract-behavior.md", "skills/ba-presale/SKILL.md", "skills/ba-presale/steps/build.md"]
    },
    {
      "name": "presale_handoff_bundle",
      "baseline": 41386,
      "max": 48000,
      "paths": ["core/contract.yaml", "core/contract-behavior.md", "skills/ba-presale/SKILL.md", "skills/ba-presale/steps/handoff.md"]
    },
    {
      "name": "presale_status_bundle",
      "baseline": 32993,
      "max": 38500,
      "paths": ["core/contract.yaml", "core/contract-behavior.md", "skills/ba-presale/SKILL.md", "skills/ba-presale/steps/status.md"]
    },
    {
      "name": "intake_bundle",
      "baseline": 32702,
      "max": 37500,
      "paths": ["core/contract.yaml", "core/contract-behavior.md", "skills/ba-start/SKILL.md", "skills/ba-start/steps/intake.md"]
    },
    {
      "name": "backbone_bundle",
      "baseline": 30715,
      "max": 35500,
      "paths": ["core/contract.yaml", "core/contract-behavior.md", "skills/ba-start/SKILL.md", "skills/ba-start/steps/backbone.md"]
    },
    {
      "name": "status_bundle",
      "baseline": 31075,
      "max": 36000,
      "paths": ["core/contract.yaml", "core/contract-behavior.md", "skills/ba-start/SKILL.md", "skills/ba-start/steps/status.md"]
    },
    {
      "name": "stories_bundle",
      "baseline": 30832,
      "max": 35500,
      "paths": ["core/contract.yaml", "core/contract-behavior.md", "skills/ba-start/SKILL.md", "skills/ba-start/steps/stories.md"]
    },
    {
      "name": "wireframes_bundle",
      "baseline": 34276,
      "max": 39500,
      "paths": ["core/contract.yaml", "core/contract-behavior.md", "skills/ba-start/SKILL.md", "skills/ba-start/steps/wireframes.md"]
    },
    {
      "name": "srs_core_bundle",
      "baseline": 35445,
      "max": 41000,
      "paths": ["core/contract.yaml", "core/contract-behavior.md", "skills/ba-start/SKILL.md", "skills/ba-start/steps/srs.md", "skills/ba-start/steps/srs-core.md", "skills/ba-start/steps/srs-assembly.md"]
    },
    {
      "name": "srs_wireframe_bundle",
      "baseline": 38431,
      "max": 44500,
      "paths": ["core/contract.yaml", "core/contract-behavior.md", "skills/ba-start/SKILL.md", "skills/ba-start/steps/srs.md", "skills/ba-start/steps/srs-core.md", "skills/ba-start/steps/srs-wireframes.md", "skills/ba-start/steps/srs-assembly.md"]
    }
  ]
}
```

## Cách chạy

```bash
scripts/check-token-budget.sh
```

Nếu budget fail, ưu tiên:

1. Gỡ rule trùng lặp khỏi runtime policy files.
2. Tách bớt step file nếu một path cụ thể phình quá nhanh.
3. Đưa phần deterministic sang CLI hoặc manifest machine-readable thay vì prose.
