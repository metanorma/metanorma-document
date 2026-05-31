# 16 — Theme as lutaml-model with YAML schema — DONE

## What was done

Converted `Theme` from a plain Ruby class with `attr_accessor` + `VALID_KEYS` + manual YAML parsing to a proper `Lutaml::Model::Serializable` with typed attributes.

### Schema definition
- 65 typed attributes declared with lutaml-model `attribute` DSL
- Types: `:string` (colors, fonts, CSS), `:boolean` (preface_wrap), `:hash` (logos)
- Collection arrays: `:string, collection: true` (publishers, preface_order, clause_order, toc_filter_types)
- All defaults declared via `default: -> { ... }` procs
- Nil-by-default attributes (accent_deep, warm, dark_note_bg, etc.) have no default

### What was eliminated
- `VALID_KEYS` constant — no longer needed, attribute declarations ARE the schema
- `SETTERS` constant — lutaml-model handles key→setter mapping
- Manual `initialize` with 60+ instance variable assignments — lutaml-model handles initialization
- `apply_overrides` method — `from_yaml` handles deserialization
- `require "yaml"` + `YAML.safe_load_file` — `File.read(path)` + `from_yaml` replaces it

### What was preserved
- `theme_dir` as regular `attr_accessor` (not a YAML attribute, set programmatically)
- `THEMES_DIR`, `TEMPLATES_ROOT` constants
- All behavior methods: `to_css_root`, `to_css_extras`, `resolve_template`, `resolve_asset`, etc.
- `load(flavor)`, `from_file`, `from_directory` class methods
- Full backward compatibility — all 111 theme specs pass unchanged

### Schema introspection
```ruby
Metanorma::Html::Theme.attributes.size  # => 65
Metanorma::Html::Theme.attributes[:preface_wrap].type  # => Lutaml::Model::Type::Boolean
Metanorma::Html::Theme.attributes[:publishers].collection?  # => true
Metanorma::Html::Theme.attributes[:logos].type  # => Lutaml::Model::Type::Hash
```

### Why this matters
- **Flavor authors** get schema-level documentation — every valid key, its type, and default value is declared in one place
- **Type safety** — wrong types in YAML are caught at load time by lutaml-model
- **No silent ignores** — with the old `VALID_KEYS` + `SETTERS` pattern, unknown keys were silently skipped. Now lutaml-model handles key mapping
- **Round-tripping** — themes can be loaded, modified, and serialized back to YAML via `to_yaml`
- **Future-proof** — when theme configs move to per-flavor gems, the model stays the same; only the load path changes

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
