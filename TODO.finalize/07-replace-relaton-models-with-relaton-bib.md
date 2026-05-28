# 07 — Replace relaton models with relaton-bib library

## Problem
The project has 50 relaton model files in `lib/metanorma/document/relaton/` that duplicate models already provided by `relaton-bib` (at `~/src/relaton/relaton-bib`). The relaton-bib library has 52 model files that are the canonical, maintained versions.

Our duplicate models:
- Diverge from the canonical relaton-bib models
- Require manual sync when relaton-bib is updated
- Add maintenance burden for no benefit
- Are incomplete compared to relaton-bib

## relaton-bib capabilities
- Full `lutaml-model::Serializable` models for: Address, Affiliation, BibItem, Contributor, Copyright, Date, DocIdentifier, Organization, Person, Series, Title, etc.
- XML serialization/deserialization
- Hash conversion support
- Actively maintained at `~/src/relaton/relaton-bib`

## Integration approach

### Phase 1: Add dependency
```ruby
# metanorma-document.gemspec
spec.add_dependency "relaton-bib"
```

### Phase 2: Replace model references
Replace all `Metanorma::Document::Relaton::*` references with `Relaton::Bib::Model::*`:

| Our model | relaton-bib equivalent |
|---|---|
| `Relaton::Address` | `Relaton::Bib::Model::Address` |
| `Relaton::Organization` | `Relaton::Bib::Model::Organization` |
| `Relaton::Person` | `Relaton::Bib::Model::Person` |
| `Relaton::Contributor` | `Relaton::Bib::Model::Contributor` |
| `Relaton::CopyrightAssociation` | `Relaton::Bib::Model::Copyright` |
| `Relaton::DocumentIdentifier` | `Relaton::Bib::Model::DocIdentifier` |
| `Relaton::BibliographicDate` | `Relaton::Bib::Model::Date` |
| `Relaton::TitleType` | `Relaton::Bib::Model::Title` |
| ... (all 50 files) | ... |

### Phase 3: Update XML mappings
The document model's XML mappings reference relaton types. These need updating:
```ruby
# Before:
attribute :contributor, Metanorma::Document::Relaton::Contributor, collection: true

# After:
attribute :contributor, Relaton::Bib::Model::Contributor, collection: true
```

### Phase 4: Remove our relaton directory
Delete `lib/metanorma/document/relaton/` entirely after all references are updated.

## Steps
1. Add `relaton-bib` dependency to gemspec
2. Create compatibility shim if needed (module aliases)
3. Update all document model files that reference `Metanorma::Document::Relaton::*`
4. Run full spec suite after each model replacement
5. Handle any schema differences between our models and relaton-bib
6. Remove `lib/metanorma/document/relaton/` once fully migrated
7. Update `lib/metanorma/document/relaton.rb` autoloader
8. Add integration specs for relaton-bib model usage

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
