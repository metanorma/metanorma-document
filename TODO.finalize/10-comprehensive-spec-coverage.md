# 10 — Comprehensive spec coverage for HTML rendering pipeline

## Problem
Current specs cover basic rendering (150 tests) but lack coverage for:
- Cross-flavor rendering (only ISO tested)
- Edge cases in formula/table/figure rendering
- Theme loading and config validation
- Drop behavior
- Liquid template rendering
- Footnote collection edge cases
- Error handling

## Current spec structure
```
spec/metanorma/
├── html/
│   ├── generator_spec.rb      — 15 tests, ISO only
│   ├── renderer/
│   │   ├── base_renderer_spec.rb  — dispatch registry tests
│   │   ├── drops_spec.rb          — basic drop rendering
│   │   └── class_ownership_spec.rb — renderer class hierarchy
│   └── renderer_spec.rb           — combined tests
├── standard_document/
├── mirror/
└── ... flavor specs
```

## Target spec structure

### 1. Theme specs (`spec/metanorma/html/theme_spec.rb`)
- Loading default theme
- Loading flavor-specific theme from YAML
- Theme falls back to defaults for missing keys
- CSS root generation correctness
- Dark mode block generation
- Invalid config handling

### 2. Drop specs (one per drop)
```
spec/metanorma/html/drops/
├── footnote_drop_spec.rb
├── formula_drop_spec.rb
├── biblio_entry_drop_spec.rb
├── figure_drop_spec.rb
├── note_drop_spec.rb
├── admonition_drop_spec.rb
├── example_drop_spec.rb
├── sourcecode_drop_spec.rb
└── toc_entry_drop_spec.rb
```
Each spec should verify:
- Correct HTML generation from model
- Edge cases (nil fields, empty collections)
- Liquid template rendering output

### 3. Cross-flavor rendering specs
```ruby
# spec/metanorma/html/generator_spec.rb
[ISO, IEC, IEEE, ITU, OGC, BIPM, CC, IHO, OIML].each do |flavor|
  describe "#{flavor} rendering" do
    it "generates valid HTML without Liquid errors"
    it "applies correct theme colors"
    it "renders cover page with flavor-specific elements"
  end
end
```

### 4. Component rendering specs
```
spec/metanorma/html/renderer/
├── tables_spec.rb      — table rendering (sticky caption, scrolling, colgroup)
├── formulas_spec.rb    — formula rendering (stem, where, numbering)
├── footnotes_spec.rb   — footnote collection, numbering, back-references
├── biblio_spec.rb      — biblio entries, ordinal parsing, links
├── figures_spec.rb     — figure rendering, lightbox
├── lists_spec.rb       — ordered, unordered, definition lists
├── inline_spec.rb      — xrefs, math, strong, em, concepts
└── sections_spec.rb    — section nesting, heading levels, TOC
```

### 5. Liquid template specs
Verify each template renders correctly in isolation with mock drops.

### 6. Asset pipeline specs
- CSS bundling
- JS bundling  
- Font inclusion
- Theme CSS variable injection

## Steps
1. Create spec files for each Drop class
2. Add theme loading specs
3. Add cross-flavor generator specs (where fixtures exist)
4. Add component-level rendering specs for tables, formulas, footnotes, biblio
5. Add Liquid template isolation specs
6. Add asset pipeline specs
7. Measure coverage with SimpleCov and target >90%

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
