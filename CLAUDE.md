# metanorma-document — Project Rules

## ABSOLUTE RULE: NEVER use Nokogiri on document XML, and no freeform XML strings

Document XML (presentation XML) is parsed into lutaml-model objects. All access to document content MUST go through the model object graph — typed attributes, `element_order`, `each_mixed_content`, etc.

NEVER:
- Call `to_xml` on a model object and then parse that XML with Nokogiri
- Use Nokogiri to strip, transform, or manipulate document XML content
- Use Nokogiri CSS selectors on document XML to find elements
- Hold markup-bearing content in a plain string attribute (`map_all_content` / `map_content` on content that can contain elements) — EVERY document payload must be modeled as typed lutaml-model classes. This is why `metanorma-extension` (semantic-metadata, presentation-metadata, UnitsML, source-highlighter-css) and `misc-container` (presentation-metadata) are fully modeled under `standard_document/metadata/`.

The HTML renderer must use the model's typed attributes and the rendering pipeline (`render_paragraph`, `render_mixed_inline`, etc.) to produce HTML. Nokogiri is only acceptable for processing non-document asset files (e.g., SVG logo files) — never on anything parsed from or derived from a document.

## ABSOLUTE RULE: Use `each_mixed_content` for mixed content nodes

For any node with `mixed? == true`, you MUST use `each_mixed_content` to iterate children. This provides the full sequence of text nodes and elements in correct order.

Do NOT:
- Use only typed attributes (like `paragraphs`, `title`) for rendering — these only give mapped elements, not text nodes
- Use `element_order` for inline content — it only shows element children, not interleaved text

`render_ordered_content` uses `element_order` and is acceptable for block-level sections (which contain only element children like paragraphs and lists). But for paragraphs and inline content containers, `each_mixed_content` is mandatory.

## ABSOLUTE RULE: No regex for HTML stripping

Never use regex (`/<[^>]+>/`) to strip HTML tags from rendered output. Text extraction must work directly on model objects via `extract_plain_text` (which walks `element_order` and typed attributes). If you need plain text from a model element, use `extract_plain_text(element)`, not `strip_html(render(element))`.
