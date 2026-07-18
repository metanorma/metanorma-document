# Bug 08: list items render with both browser and PXML bullets

## Summary
In presentation XML, list items carry their authoritative marker in
`<fmt-name>` (the autonum result: `—` for unordered lists, `1.` etc. for
ordered lists). `FmtNameElement` is registered as a transparent inline
wrapper, so `render_list_item_content` emitted the marker inline in the
item text — while the HTML `<ul>`/`<ol>` still got the browser's default
`list-style` marker on top. Every labeled list item showed two markers.

## Affected Version
`metanorma-document` 0.2.12

## Reproduction

```ruby
require "metanorma/document"

doc = Metanorma::OimlDocument::Root.from_xml(<<~XML)
  <standard xmlns="https://www.metanorma.org/ns/standoc">
    <sections>
      <clause><p>Intro:</p>
        <ul><li>
          <fmt-name><semx element="autonum">—</semx></fmt-name>
          <p>item text</p>
        </li></ul>
      </clause>
    </sections>
  </standard>
XML
html = Metanorma::Html::Generator.generate(doc)
# => <li> contained an inline "—" AND the browser's disc bullet
```

## Fix
`render_unordered_list` / `render_ordered_list` now detect items whose
`fmt-name` yields a non-empty label. In that case the list gets the
`mn-labeled-list` class (`list-style: none`, hanging indent via
`components/lists.css`), the `fmt-name` is skipped in the inline walk
(new `skip_classes:` option on `render_mixed_content_in_order`), and the
label is rendered as the item marker in `<span class="li-label">`.
Lists without `fmt-name` keep the browser's default markers.

Covered by the "labeled lists (fmt-name markers)" examples in
`spec/metanorma/html/renderer/base_renderer_spec.rb`.
