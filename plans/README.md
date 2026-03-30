# Plans Workspace

`plans/` is a local runtime workspace for BA-kit.

Generated work plans and report artifacts belong here while you are running `/ba-start`, but they should not be version-controlled in this repository.

Expected runtime structure:

```text
plans/
  reports/
    intake-{slug}-{date}.md
    frd-{date}-{slug}.md
    user-stories-{date}-{slug}.md
    srs-{date}-{slug}.md
    wireframe-state-{date}-{slug}.md
  {date}-{slug}/
    plan.md
```

If you want to keep sample outputs for documentation, move sanitized examples into `docs/` or a dedicated `examples/` directory instead of committing them under `plans/`.
