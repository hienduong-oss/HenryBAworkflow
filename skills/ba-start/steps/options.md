# BA Start Step - Options

This step requires:

- `core/contract.yaml`
- `core/contract-behavior.md`

Use this step for pre-backbone solution optioning when intake has already locked the business problem but the solution shape still needs explicit generation, comparison, selection, or bypass.

## Prerequisites

- Resolve slug and date using the shared contract
- Require `paths.intake`
- Read `paths.plan` when it exists
- Reuse the intake decision-ledger status before generating or mutating any option artifact

## Supported Intents

- generate option pack from intake
- select an existing option
- skip optioning explicitly

## Generation Rules

- Generate 1-3 option artifacts only
- Mark each option with `L1`, `L2`, or `L3`
- Generate `comparison.md` only when more than one viable option exists
- Keep options as solution briefs, not mini-backbones
- Write under `paths.options_root` using `paths.options_index`, `paths.option_item`, and `paths.options_comparison`
- Move the decision ledger in `paths.plan` to `options status: in-progress` while the option cycle is active
- Keep the output focused on business intent, scope shape, trade-offs, and decision support

## Selection / Skip Rules

- `--select option-02` updates `paths.plan` to `options status: completed`
- Record the selected option id and next command in `paths.plan`
- Update the chosen option row to selected and keep non-chosen options reviewable
- `--skip` updates `paths.plan` to `options status: skipped`
- Require explicit user approval before applying `--skip` when multiple viable options already exist
- After selection or skip, refresh `paths.project_home`

## Stop Conditions

- Stop when `paths.intake` is missing or the slug/date cannot be resolved exactly
- Stop when the intake ledger already says `not-needed` and the user did not explicitly request optioning
- Stop when overwrite approval is required for existing option artifacts and the user has not approved it
- Stop when selection or skip input conflicts with the current on-disk option set; follow the shared control-argument rules in `core/contract-behavior.md`
