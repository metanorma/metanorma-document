# HTML capability replacements

`Metanorma::Html::Generator.generate(document, headless: true)` returns the
standalone body layout inside a language-tagged `div`. It omits the doctype,
`html`, `head`, and `body` elements and head resources. Body scripts remain,
as in isodoc's `strip_head`. Hosts supply CSS and fonts. `generate_body`
remains available when the host also supplies navigation and layout. The CLI
also accepts `metanorma-document to-html INPUT --headless`.

## Forms and footnotes

Input controls retain their model attributes. They are interactive unless
`disabled` or `readonly` is set. Shared paragraphs, table cells, and inline
containers accept typed `label`, `select`, `option`, and `textarea` models.
A select's `value` selects the matching option. Textarea values and labels
are escaped/rendered through Liquid, including mixed inline label content.

Standoc owns its block `Form` model. Its direct `input` children currently
use `FormInput`, which does not retain input-specific attributes, and direct
labels do not map HTML's `for` attribute. The supported replacement is to
place controls and labels in a paragraph inside the form **before model
parsing**. The shared paragraph model retains them. Existing parsed models
cannot recover fields their schema discarded. Changing Standoc's direct
child mappings belongs in Standoc, which remains read-only in this task.

Footnotes are laid out during rendering: each reference has a unique anchor,
endnotes link back to every occurrence, and table notes have independent
scopes and link targets. Adjacent markers are separated with CSS. Native
links work without JavaScript; existing annotation popups remain available.

## Front matter

A flavor's root renderer calls `render_front_matter(document)` before its
main content. `StandardRenderer` already does this. Flavor renderers that
assemble their own cover and boilerplate should replace that assembly with
this hook when ported. Existing renderer overrides continue to own their
output until they adopt the hook; theme configuration alone does not replace
a flavor's Ruby root renderer.

Theme YAML accepts:

```yaml
cover_template: cover.html.liquid
titlepage_template: titlepage.html.liquid
intro_template: intro.html.liquid
boilerplate_placement: intro
cover_notes_slot: cover
```

Slots render in cover, titlepage, intro order. Templates resolve in the
theme's `templates/` directory, then shared templates. An absent cover
falls back to `render_coverpage`; absent titlepage and intro slots emit
nothing. The default boilerplate placement is `after_cover`, preserving
shared-renderer output. An unknown placement or a placement requiring an
unconfigured template raises an error.

Templates receive the typed `bibdata` model and `title`, `doc_id`, `language`, `publisher_name`,
`stage_html`, `tc_html`, and `dates_html` from the model-backed renderer.
Use Liquid's `escape` filter for plain text. Rendered `*_html` fields are
already markup. Flavors can extend `front_matter_assigns(document)` to
provide additional metadata; legacy metadata dictionaries are not silently
re-created or passed as untyped document XML.

Legacy `boilerplate-*-destination` IDs become explicit fields:
`front_matter.copyright_html`, `.license_html`, `.legal_html`, and
`.feedback_html`. These lazy fields render typed statement models;
set `boilerplate_placement: template` when using these individual fields. A
template can instead output `boilerplate_html` at the configured placement
for the complete block. Use either individual fields or the complete block
to avoid printing the same material twice.

Legacy `coverpage-note-destination` becomes `cover_notes_html`. When front
matter templates are configured, notes, admonitions, and paragraphs marked `coverpage="true"` are
collected from the model graph, emitted at the configured slot, and omitted
from main content without mutating the model or rewriting generated HTML.
The template must output the field. With no front-matter templates,
existing rendering of the notes is preserved.

Per-flavor templates, additional metadata, assets, and renderer adoption are
the B2/B3 migration work. These hooks establish a replacement mechanism;
they are not per-flavor visual parity evidence. Parity sign-off and the
engine dispatch switch remain governed by the epic's regression harness.
