 # 07 — Integrate relaton-bib library (partially complete)

## Status
- **Done**: relaton-bib dependency added, 4 models replaced via inheritance, `require` at module level
- **Blocked**: Most models have incompatible XML schemas (different attribute names/types, different XML mappings)

## What was done
1. Added `relaton-bib ~> 2.1` to gemspec dependency
2. Added `require "relaton/bib"` to `lib/metanorma/document/relaton.rb`
3. Replaced 4 models with inheritance from relaton-bib:
   - `Phone` < `::Relaton::Bib::Phone` (exact match)
   - `PriceType` < `::Relaton::Bib::Price` (exact match)
   - `BibItemLocality` < `::Relaton::Bib::Locality` (exact match)
   - `Edition` < `::Relaton::Bib::Edition` (inherits + adds `language` attribute)

## Why most models can't be directly replaced
The 53 relaton models in our project have different XML schemas from relaton-bib's models:

| Difference | Our models | relaton-bib |
|---|---|---|
| Attribute names | `on` (BibliographicDate), `bib_locality` (LocalityStack), `validity_begins` (ValidityType) | `at`, `locality`, `begins` |
| Attribute types | `Components::DataTypes::*` throughout | `LocalizedString`, `LocalizedMarkedUpString` |
| XML mapping | `map_attribute` for medium, `map_all_content` for logo | `map_element` for medium, `map_element "image"` for logo |
| Extra attributes | `language` on Edition, `id` on DocumentIdentifier, `stage_abbreviation` on DocumentStatus | Not present |
| Mixed content | Used in TypedTitleString (em/fn/stem/strong/sub/sup/tt/variant) | Plain content |
| Model nesting | `CopyrightOwner` wraps `Organization` | `Contributor` as owner |

A full replacement requires updating all 86 consuming references and adapting to relaton-bib's API. This is a separate project-level migration.

## Remaining work for full migration
1. Update consuming code (86 references) to use relaton-bib attribute names
2. For models with extra attributes: inherit from relaton-bib and add extras
3. For models with structural differences: create adapter classes
4. Remove `lib/metanorma/document/relaton/` once fully migrated
5. Update autoload configuration
6. Integration specs for relaton-bib model usage

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
