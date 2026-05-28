# 06 — Integrate pubid library for publication identifier handling

## Problem
The project has its own relaton-based metadata models for publication identifiers, but the `pubid` gem at `../../mn/pubid` already provides:
- Full parsing and rendering of identifiers for 20+ flavors (ISO, IEC, IEEE, ITU, etc.)
- `lutaml-model`-based serializable models with polymorphic type dispatch
- Human-readable, MR string, and URN rendering
- Structured components (publisher, stage, edition, language, locality)

Our current biblio rendering manually parses `biblio-tag` mixed content to extract ordinal/pubid. With pubid, we can parse the identifier string directly and render it properly for each flavor.

## Integration points

### 1. Add `pubid` dependency
```ruby
# metanorma-document.gemspec
spec.add_dependency "pubid"
```

### 2. Replace biblio-tag parsing with pubid parsing
In `standard_renderer.rb`, instead of `split_biblio_tag` (manual mixed content walking):
```ruby
# Parse docidentifier string through pubid
doc_id = item.docidentifier.first&.content
if doc_id
  identifier = Pubid::Iso.parse(doc_id) # or detect flavor automatically
  pubid_html = identifier.render(context: rendering_context)
end
```

### 3. Flavor-aware identifier rendering
Each flavor renderer can provide its pubid module:
```ruby
module IsoRenderer
  def pubid_module
    Pubid::Iso
  end
end
```

### 4. Replace manual pubid CSS classes
Currently we have `.ref-publisher-name`, `.ref-doc-number`, `.ref-year` spans built manually.
With pubid's structured output, we get semantically correct identifier rendering automatically.

## Steps
1. Add `pubid` gem dependency to gemspec
2. Add `require "pubid"` to the project
3. Create `PubidHelper` module in the HTML renderer namespace
4. Replace `split_biblio_tag` with pubid-based identifier parsing in `BiblioEntryDrop`
5. Wire flavor-specific pubid modules into each flavor renderer
6. Update `BiblioEntryDrop` to use pubid for `pubid_html` generation
7. Add specs for identifier rendering per flavor
8. Remove manual biblio-tag walking code

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
