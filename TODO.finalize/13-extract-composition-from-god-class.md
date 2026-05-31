# 13 — Extract module includes into composition — DONE

## Problem
BaseRenderer is a God class with 180+ public methods from 4 mixed-in modules:
- `InlineRendering` (~590 lines, 39 methods)
- `BlockRendering` (~295 lines, 24 methods)
- `SectionRendering` (~90 lines, 8 methods)
- `PubidRendering` (~55 lines, 2 methods)

Module includes break OCP and encapsulation — all module methods become public on the single class, making it impossible to reason about responsibilities in isolation.

## Architecture

Replace `include` with composition. Each module becomes a standalone class that receives a reference to the coordinator for cross-concern calls:

```
BaseRenderer (coordinator, ~50 methods)
  ├── InlineRenderer (inline elements, 39 methods)
  ├── BlockRenderer (block elements, 24 methods)
  ├── SectionRenderer (sections, 8 methods)
  └── PubidRenderer (pubid parsing, 2 methods)
```

### Cross-concern dependencies (one-way, clean extraction)

InlineRenderer needs from coordinator:
- `escape_html`, `safe_attr`, `element_attrs`, `capture_output`, `render_liquid`
- `render_paragraph`, `render_inline_element` (recursive dispatch)
- `@output`, `@footnote_collector`, `@index_term_collector`

BlockRenderer needs from coordinator:
- `escape_html`, `safe_attr`, `element_attrs`, `capture_output`, `render_liquid`
- `render_mixed_inline`, `render_inline_element`, `render_mixed_content_in_order`
- `walk_ordered`, `block_element?`, `render` (recursive dispatch)
- `@output`, `renderer_context`

SectionRenderer needs from coordinator:
- `escape_html`, `safe_attr`, `element_attrs`, `capture_output`, `render_liquid`
- `walk_ordered`, `render`, `render_note`, `extract_plain_text`
- `@output`

PubidRenderer needs from coordinator:
- `escape_html`, `flavor_name`

### Implementation plan

1. Create `InlineRenderer` class at `lib/metanorma/html/renderers/inline_renderer.rb`
   - Receives `coordinator` in constructor
   - Moves all methods from `InlineRendering` module
   - Delegates shared utility calls to coordinator
2. Create `BlockRenderer` class at `lib/metanorma/html/renderers/block_renderer.rb`
   - Same pattern
3. Create `SectionRenderer` class at `lib/metanorma/html/renderers/section_renderer.rb`
   - Same pattern
4. Create `PubidRenderer` class at `lib/metanorma/html/renderers/pubid_renderer.rb`
   - Same pattern
5. Update `BaseRenderer` to instantiate sub-renderers and delegate
6. Update `RendererContext` to delegate through coordinator's sub-renderers
7. Update all flavor renderers (IsoRenderer, StandardRenderer, etc.) for new API
8. Update all Drop classes that call `renderer.method_name`
9. Ensure all existing specs pass

### Delegation pattern

```ruby
class BaseRenderer
  attr_reader :inline_renderer, :block_renderer, :section_renderer, :pubid_renderer

  def initialize
    @inline_renderer = InlineRenderer.new(self)
    @block_renderer = BlockRenderer.new(self)
    @section_renderer = SectionRenderer.new(self)
    @pubid_renderer = PubidRenderer.new(self)
    # ...
  end

  # Delegate for backward compatibility during migration
  def render_paragraph(...) = @block_renderer.render_paragraph(...)
  def render_em(...) = @inline_renderer.render_em(...)
  # etc.
end
```

### Flavor renderers

Sub-renderers can be extended per flavor:
```ruby
class IsoSectionRenderer < SectionRenderer
  def render_preface(preface, **)
    # ISO-specific preface ordering
  end
end
```

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
