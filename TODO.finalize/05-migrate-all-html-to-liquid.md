# 05 — Migrate all HTML generation to Liquid templates

## Problem
`base_renderer.rb` has 69 `@output <<` manual HTML injections and `standard_renderer.rb` has 25 more. The `tag()` helper also generates HTML strings directly. Only biblio entries and some block elements use Liquid templates. This violates the project rule: "All HTML output MUST use Liquid templates."

## Current state
- 17 Liquid templates exist in `lib/metanorma/html/templates/`
- 94 `@output <<` calls remain across renderers
- `tag()` helper builds HTML tags via string concatenation
- `iso_renderer.rb` builds cover pages, foreword sections entirely via manual HTML

## Target: every HTML element generated through Liquid

### Phase 1: Create missing templates for all structural HTML
Each currently hardcoded HTML pattern needs a template:

| Pattern | Template |
|---|---|
| `<div class="section-sub">` | `_section.html.liquid` |
| `<h1>/<h2>/<h3>` headings | `_heading.html.liquid` |
| `<p>` paragraphs | `_paragraph.html.liquid` |
| `<table>` with wrapper | `_table.html.liquid` |
| `<dl>` definition lists | `_definition_list.html.liquid` |
| `<ol>/<ul>` lists | `_list.html.liquid` |
| `<figure>` | already exists |
| `<blockquote>` | `_quote.html.liquid` |
| Cover page sections | `_cover_section.html.liquid` |
| Sidebar TOC | `_sidebar_toc.html.liquid` |
| `<a href>` xref links | `_xref.html.liquid` |
| `<span class="math-container">` | `_math.html.liquid` |
| `<code>/<pre>` sourcecode | already exists |
| Generic `<div>` with attrs | `_container.html.liquid` |

### Phase 2: Replace `tag()` helper
The `tag("element", attrs) { block }` pattern should be replaced with template rendering:
```ruby
# Before:
tag("div", attrs) do
  @output << "content"
end

# After:
render_liquid("_container.html.liquid", {
  "tag" => "div",
  "attrs" => attrs,
  "content_html" => captured_content,
})
```

Or better: create a generic `_element.html.liquid`:
```liquid
<{{ tag }}{% for kv in attrs %} {{ kv[0] }}="{{ kv[1] }}"{% endfor %}>
{{ content_html }}</{{ tag }}>
```

### Phase 3: Create Drop for every model type
Every model that gets rendered needs a Drop that pre-renders its HTML content:
- `SectionDrop` — renders heading + body content
- `ParagraphDrop` — renders inline content
- `TableDrop` — renders caption, header, body
- `ListDrop` — renders items
- `XrefDrop` — renders link
- etc.

## Steps
1. Inventory all `@output <<` and `tag()` patterns in both renderers
2. Create generic `_element.html.liquid` for simple tag wrapping
3. Create specialized templates for complex structures
4. Create Drops for each model type
5. Replace each `@output <<` with `render_liquid` calls
6. Remove `tag()` helper after full migration
7. Verify all 150 tests still pass at each step

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
