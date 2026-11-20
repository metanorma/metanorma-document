# Flavor-owned Liquid template hooks

A flavor registers its HTML renderer with `Metanorma::Core::Flavors` as before.
The renderer overrides the public `template_directories` hook to supply paths
inside its own gem. No change to metanorma-document's flavor table, theme files,
or global Liquid file system is needed.

```ruby
# frozen_string_literal: true

class OrganizationRenderer < Metanorma::Html::StandardRenderer
  def template_directories
    [File.expand_path("templates", __dir__), *super]
  end
end
```

The gem must package that directory. A taste renderer subclasses its base flavor
renderer and prepends its own directory in the same way. Keep values such as
fonts, colors, publishers, logos and section order in theme/config (card B2).
Use this hook for markup structure. The mechanism applies to any template name
sent through `render_liquid`, including flavor-owned names.

## Resolution contract

For every entry template and nested Liquid `render` or `include`, search:

1. The selected organization/theme's `templates/` directory, followed by its
   `extends` ancestors from nearest parent to most distant parent, if present.
2. The renderer's `template_directories`, in supplied order (taste before base).
3. The shared `Metanorma::Html::TEMPLATES_ROOT` directory.

First existing regular file wins. Missing files fall through to the next
directory; a missing entry raises `Liquid::FileSystemError`. Invalid names,
absolute paths, `..` traversal, and symlinks escaping a configured directory are
rejected. Liquid's normal rendering behavior handles missing partial errors;
this hook does not change error policy or enable strict variables globally.

A taste can override a single entry or partial and inherit the remaining
templates from its base theme. Parent theme templates take precedence over
renderer-owned templates, and nested `render` and `include` calls use the same
search order as entry templates. `Theme#theme_template_directories` exposes
this ordered list; `theme_templates_dir` still returns its first directory.

Entry names include the extension, for example `_paragraph.html.liquid`.
Partial names omit underscore and suffix: `{% render 'branding' %}` reads
`_branding.html.liquid`. A nested path such as `details/branding` reads
`details/_branding.html.liquid`. Directories may be absent; this allows a flavor
to opt into overrides incrementally.

Parsed entry templates remain cached by resolved absolute path. Each render
gets a fresh Liquid context with its own file system and partial cache, so two
flavors may share an entry template and still use different partials. This also
avoids mutating Liquid's global file system. Cached templates are deployment
assets: restart the process after changing a template file.

## Assigns and content

A replacement receives the same assigns as the existing call site. For example,
`_paragraph.html.liquid` receives `attrs` and already-rendered `content` from the
block renderer:

```liquid
<p class="organization-paragraph"{{ attrs }}>{{ content }}</p>
```

Pass values explicitly to isolated `render` partials:

```liquid
{% render 'identity', title: title, doc_id: doc_id %}
```

An override must escape plain text with Liquid's `escape` filter; already-rendered
child HTML follows the existing slot contract. New metadata must come from typed
lutaml-model objects and explicit Drops or renderer methods. Legacy IsoDoc flat
assigns such as `doctitle`, date-label variants, or `bibdata` are not automatically
available. This hook does not parse or transform document XML or offer arbitrary
Ruby callbacks. Use the existing typed rendering pipeline for child content and
`each_mixed_content` for mixed inline models.

## Cover and intro ports

The [per-flavor audit](html-override-audit/README.md) maps titlepage layout to the
existing `_cover.html.liquid` call in `StandardRenderer`. A flavor renderer that
already uses another named cover partial can put that partial in its directories
and call `render_liquid` with typed assigns. The hook does not select a cover style
or introduce metadata. A variant resolver or flavor renderer chooses document-type
variants such as UN plenary.

Most legacy intro templates combine TOC markup with empty DOM destinations for
copyright/license/feedback. The existing `document.html.liquid` owns the navigation container;
`_toc.html.liquid` renders list entries only. Override the container template
when moving navigation into an intro, and keep the entry template compatible
with its parent list. Port extra intro metadata through a flavor-owned partial. The cover/intro
capability and placement of typed boilerplate content belong to card B1. Merely
copying old destination IDs does not reproduce that behavior. This card changes
neither cover assembly nor postprocessing and does not claim per-flavor parity.

## Verification

The focused `template_overrides_spec.rb` exercises composed paragraph rendering
with real lutaml-model instances, theme priority, taste inheritance, shared
fallback, nested partials, isolation between renderers sharing a cached entry,
and invalid/missing paths. Existing template, composition and portability specs
check the surrounding contracts. Use the repo's `bundle exec rspec` entrypoint;
do not run the full suite for this card.
