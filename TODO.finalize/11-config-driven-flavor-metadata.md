# 11 — Config-driven flavor metadata: eliminate boilerplate renderers — DONE

## What was done
All 13 theme YAML files contain publisher metadata:
```yaml
publishers:
  - "ISO"
publisher_name: "ISO"
logos:
  "ISO": "iso-logo.svg"
```

BaseRenderer reads publishers/logos from theme via `theme.publishers`, `theme.publisher_name`, `theme.logos`. No renderer code overrides these.

10 flavor renderers are empty shells (0 methods, just inherit IsoRenderer). They exist because `Generator` maps document classes to renderer classes, but all customization comes from theme YAML config.

Theme auto-resolves from document type via `FLAVOR_MAP` — no manual `theme` override needed in any renderer.

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
