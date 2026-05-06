# BA Start Step - Options

## Prerequisites

- Resolve slug and date using the shared contract
- Require `paths.intake`
- Read `paths.plan` when it exists

## Supported Intents

- generate option pack from intake
- select an existing option
- skip optioning explicitly

## Generation Rules

- Generate 1-3 option artifacts only
- Generate or open the option cycle by updating `paths.plan` to `options status: in-progress`
- Mark each option with `L1`, `L2`, or `L3`
- Generate `comparison.md` only when more than one viable option exists
- Keep options as solution briefs, not mini-backbones

## Selection / Skip Rules

- `--select option-02` records `selected option` in `paths.plan` and updates `options status: completed`
- `--skip` updates `paths.plan` to `options status: skipped`
- After selection or skip, refresh `paths.project_home`
