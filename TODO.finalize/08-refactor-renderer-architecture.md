# 08 — Refactor renderer architecture for OCP and DRY

## Problem
The renderer hierarchy (`BaseRenderer` → `StandardRenderer` → `IsoRenderer` etc.) has several architectural issues:

### 1. Monolithic base_renderer.rb (1755 lines)
The base renderer handles everything: HTML structure, asset pipeline, inline rendering, block rendering, table rendering, formula rendering, footnote collection, etc. This violates SRP.

### 2. Duplicated theme override pattern
All 15 flavor renderers override `def theme` with nearly identical `Theme.new.tap` blocks. This should be config-driven (see TODO 04).

### 3. Duplicated publisher metadata methods
Every flavor renderer has identical `flavor_publishers`, `flavor_publisher_name`, `publisher_logo_map` methods:
```ruby
# Repeated in 12 renderers:
def flavor_publishers(_doc_id)  %w[ISO]    end
def flavor_publisher_name       "ISO"       end
def publisher_logo_map          { ... }     end
```
This data should live in config/theme files.

### 4. `@output <<` imperative pattern
The renderer uses `@output <<` for all HTML generation. Methods must write to `@output` instead of returning strings, making composition difficult. This is partially addressed by TODO 05 (Liquid migration), but the core architecture needs refactoring regardless.

### 5. Generator::setup! hardcodes all renderers
The generator manually lists all 15+ renderer registrations. New flavors require code changes. Should be auto-discovered or config-driven.

## Proposed architecture

### Module decomposition of BaseRenderer
```
Metanorma::Html
├── Generator (entry point, auto-discovers renderers)
├── Theme (config-driven, loaded from YAML)
├── AssetPipeline (CSS/JS bundling)
├── FootnoteCollector (footnote dedup/numbering)
├── Drops:: (Liquid drop classes)
├── Templates:: (Liquid template loading/caching)
├── Renderers::
│   ├── BaseRenderer
│   │   ├── StructureRenderer (document skeleton, head, body)
│   │   ├── BlockRenderer (div, section, paragraph, heading)
│   │   ├── InlineRenderer (text, strong, em, xref, math, fn)
│   │   ├── TableRenderer (table, caption, rows, cells)
│   │   ├── ListRenderer (ol, ul, dl)
│   │   └── MediaRenderer (figure, image, sourcecode)
│   ├── StandardRenderer < BaseRenderer (biblio, terms, annexes)
│   └── {Flavor}Renderer < StandardRenderer (cover, theme, logos)
```

### Publisher metadata in theme config
```yaml
# data/themes/iso.yaml
primary: "#b3000c"
publishers: ["ISO"]
publisher_name: "ISO"
logos:
  iso: "iso-logo.svg"
```

### Auto-discovery of flavor renderers
```ruby
# Generator discovers renderers via naming convention
# IsoDocument::Root → IsoRenderer (autoloaded)
```

## Steps
1. Extract `FootnoteCollector` into its own file (already separate, verify)
2. Extract inline rendering methods into `InlineRenderer` mixin
3. Extract block rendering methods into `BlockRenderer` mixin
4. Extract table rendering into `TableRenderer` mixin
5. Extract media rendering into `MediaRenderer` mixin
6. Move publisher metadata to theme config files
7. Make Generator auto-discover flavor renderers
8. Add specs for each extracted module independently
9. Reduce `base_renderer.rb` to ~300 lines (orchestration + shared helpers)

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
