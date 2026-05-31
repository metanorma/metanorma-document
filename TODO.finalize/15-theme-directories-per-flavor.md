# 15 — Theme directories per flavor with data-centric config — DONE

## What was done

### Theme class changes:
- Added `theme_dir` attribute (set when loaded from directory, nil for flat file themes)
- `Theme.load(flavor)` now checks for directory format first (`data/themes/{flavor}/theme.yaml`), falls back to flat file (`data/themes/{flavor}.yaml`)
- Extracted `from_file`, `from_directory`, `apply_overrides` class methods for clean separation
- Added `theme_templates_dir` — returns `{theme_dir}/templates/` if it exists
- Added `theme_assets_dir` — returns `{theme_dir}/assets/` if it exists
- Added `theme_css_path` — returns `{theme_dir}/custom.css` if it exists
- Added `resolve_template(template_name)` — checks flavor templates dir first, falls back to shared templates
- Added `resolve_asset(filename)` — checks flavor assets dir, returns nil if not found

### BaseRenderer changes:
- `render_liquid` uses `theme.resolve_template(template_name)` instead of hardcoded `File.join(TEMPLATES_ROOT, ...)`
- `load_logo_svg` checks `theme.resolve_asset(filename)` before shared `LOGO_DIR`
- `build_styles` appends `theme.theme_css_path` content if present

### Directory-based theme structure (opt-in):
```
data/themes/
  iso.yaml              # flat file — still works as before
  ogc.yaml              # flat file — still works as before
  {flavor}/             # directory format — new support
    theme.yaml          # palette, fonts, layout, ordering, publisher metadata
    custom.css          # per-flavor CSS overrides (optional)
    templates/          # per-flavor Liquid template overrides (optional)
      _cover.html.liquid
    assets/             # per-flavor assets: logos, images (optional)
      {flavor}-logo.svg
```

### Backward compatibility:
- All 13 existing flat YAML theme files continue to work unchanged
- `theme_dir` is nil for flat-file themes, so resolution always falls through to shared paths
- No migration needed — directory format is opt-in

### Specs added:
- 12 new specs in `theme_spec.rb` covering directory loading, template/asset/CSS resolution, backward compat

### Future consideration:
When theme config moves to per-flavor gems, `Theme.load` can be extended to search gem data directories. The API (`theme.resolve_template`, `theme.resolve_asset`, etc.) stays the same — only the path resolution changes.

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
