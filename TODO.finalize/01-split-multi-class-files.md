# 01 — Split multi-class files into one-class-per-file

## Problem
Several model files contain multiple classes in a single file, violating the one-class-per-file convention. This makes it harder to find code, increases merge conflicts, and breaks the autoloading convention.

## Files to split

| Current file | Classes to extract | New file(s) |
|---|---|---|
| `lib/metanorma/document/relaton/address.rb` | `FormattedAddress` | `relaton/formatted_address.rb` |
| `lib/metanorma/document/relaton/copyright_association.rb` | `CopyrightOwner` | `relaton/copyright_owner.rb` |
| `lib/metanorma/document/relaton/organization.rb` | `LogoElement` | `relaton/logo_element.rb` |
| `lib/metanorma/document/relaton/place_type.rb` | `RegionElement` | `relaton/region_element.rb` |
| `lib/metanorma/document/components/ancillary_blocks/sourcecode_block.rb` | `SourcecodeBody`, `CalloutAnnotation` | `sourcecode_body.rb`, `callout_annotation.rb` |
| `lib/metanorma/document/components/blocks/requirement_model.rb` | All 8 classes → separate files | `classification_value.rb`, `requirement_classification.rb`, `requirement_description.rb`, `requirement_inherit.rb`, `requirement_base.rb`, `requirement_model.rb`, `recommendation_model.rb`, `permission_model.rb` |
| `lib/metanorma/document/components/multi_paragraph/quote_block.rb` | `QuoteAuthorElement` | `quote_author_element.rb` |
| `lib/metanorma/document/components/reference_elements/source_element.rb` | `SourceOrigin`, `SourceModification` | `source_origin.rb`, `source_modification.rb` |
| `lib/metanorma/document/components/tables/table_block.rb` | `ColElement`, `ColGroupElement` | `col_element.rb`, `col_group_element.rb` |
| `lib/metanorma/document/components/tables/table_section.rb` | `TableSection`, `TableHeadSection`, `TableBodySection`, `TableFootSection` | `table_section.rb`, `table_head_section.rb`, `table_body_section.rb`, `table_foot_section.rb` |

## Steps
1. Extract each class into its own file with proper module namespace
2. Add `autoload` or `require_relative` entries in the parent module
3. Verify all XML round-trip specs still pass
4. Ensure no circular dependency issues after split

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
