# 14 — Config-driven preface and clause ordering — DONE

## What was done

### Theme config attributes added:
- `preface_order` — array of section names, controls rendering order (default: `foreword introduction abstract clause acknowledgements executivesummary`)
- `preface_wrap` — boolean, wraps preface content in a container div with heading (default: `false`)
- `clause_order` — array of section names for clause ordering (default: `sections annex bibliography indexsect`)
- `toc_filter_types` — array of clause types to exclude from preface rendering (default: `[]`)

### All 13 theme YAML files updated:
- ISO, IEC, IEEE, IETF, ITU, IHO, CC, BIPM, OIML, PDFA, Ribose, ICC: default ordering
- OGC: `preface_order: [clause]`, `preface_wrap: true`, `toc_filter_types: [toc]`

### Code changes:
- `Theme` — added `preface_order`, `preface_wrap`, `clause_order`, `toc_filter_types` to VALID_KEYS, attr_accessor, and defaults
- `SectionRenderer` — config-driven `render_preface` reads from theme, delegates to `render_ordered_preface` or `render_wrapped_preface` based on `preface_wrap`
- `BaseRenderer` — added `render_preface` delegation to section_renderer
- `IsoRenderer` — deleted hardcoded `render_preface` method (config-driven version replaces it)
- `OgcRenderer` — deleted hardcoded `render_preface` override (now empty shell, all behavior from YAML)
- Template `_ogc_preface.html.liquid` renamed to `_wrapped_preface.html.liquid` (generic name)

### Specs added:
- `config_preface_spec.rb` — 8 specs covering ordered mode, wrapped mode, clause filtering, and delegation
- `theme_spec.rb` — 4 specs for section ordering defaults and OGC overrides

### Key principle enforced:
No flavor-specific knowledge (no "ogc", no hardcoded ordering) in generic renderer code. All behavior comes from theme YAML config.

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
