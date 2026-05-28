# 09 — Eliminate code smells and enforce project constraints

## Problem
Several code patterns violate the project's standing constraints. These need systematic cleanup.

### Violations to fix

#### 1. `respond_to_missing?` / `method_missing` in base_renderer.rb
```ruby
# lines 99-101 — ProxyOutput class uses method_missing
def respond_to_missing?(method_name, include_private = false)
  renderer_context.respond_to?(method_name, include_private)
end
def method_missing(method_name, ...)
  renderer_context.public_send(method_name, ...)
end
```
This should use explicit delegation or a well-defined interface instead of `method_missing` + `respond_to_missing?`.

#### 2. `send` / `public_send` in base_renderer.rb
The `method_missing` above delegates via `public_send`. The `lookup_dispatch` pattern dispatches via `send`:
```ruby
def lookup_dispatch(type_class, registry_name)
  # ... returns method name, then called via send
end
```
This should use a hash-based dispatch table or proper method objects instead.

#### 3. `instance_variable_get` / `instance_variable_set`
Search for and eliminate any usage:
```bash
grep -rn "instance_variable_" lib/
```

#### 4. Nokogiri used for HTML reading/parsing
The project constraint says Nokogiri is ONLY for building HTML fragments, never for XML parsing/reading. Verify no violations exist.

#### 5. `tag()` helper mixes HTML generation concerns
The `tag()` helper in base_renderer.rb builds HTML strings. This should be a Liquid template call (see TODO 05).

### Additional cleanups

#### 6. Frozen string literals
Ensure all Ruby files start with `# frozen_string_literal: true`

#### 7. Consistent method visibility
Audit public vs private method placement — implementation methods should be private

#### 8. Remove dead code
- `safe_attr` patterns that always return nil
- Unused renderer methods
- Stale TODO comments in code

#### 9. Proper type checking
Replace all `is_a?` checks with dispatch registry lookups where possible. The type registry (`render_registry`, `inline_registry`) is the right approach — extend it to cover all dispatch cases.

## Steps
1. Replace `ProxyOutput` `method_missing` with explicit method forwarding or simple delegation
2. Replace `lookup_dispatch` + `send` with hash-based dispatch table that stores callable objects
3. Grep for and remove any `instance_variable_get/set` usage
4. Audit Nokogiri usage to ensure it's only for HTML fragment building
5. Add `# frozen_string_literal: true` to any files missing it
6. Run RuboCop and fix all offenses
7. Audit method visibility — move internal methods to private
8. Remove dead code and stale comments

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
