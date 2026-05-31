# 05 — Migrate all HTML generation to Liquid templates — DONE

All HTML element generation uses Liquid templates. Zero raw HTML string injection via `@output <<` remains. The `tag()` helper has been removed from `base_renderer.rb`. All remaining `@output <<` calls are text streaming (`escape_html`, whitespace, raw content passthrough) — not HTML element generation.

32+ Liquid templates exist in `lib/metanorma/html/templates/`. The generic `_element.html.liquid` handles most tag wrapping. Specialized templates exist for tables, lists, figures, headings, math, links, etc.

### OOP Liquid pattern
All rendering uses the `capture_output` + `render_liquid` pattern:
1. Capture child content into a Ruby string via `capture_output`
2. Pass captured content to `render_liquid("_template.html.liquid", assigns)`
3. Result is appended to `@output` by the caller

Drop classes (`Drops::*`) are used for complex objects that need pre-rendered HTML fields (e.g. `BiblioEntryDrop`, `FigureDrop`).

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
