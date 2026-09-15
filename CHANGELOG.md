## [Unreleased]

### Added

- Full document model for all Metanorma XML flavors: ISO, IEC, IEEE, IETF, IHO, OIML, BIPM, ITU, OGC, CC, Ribose, and Standoc
- Autoload-based lazy loading across all modules — replaces eager `require_relative` chains
- Roundtrip test suite verifying XML parse → serialize fidelity for ISO, BIPM, CC, ITU, OGC, OIML, and collections
- GHA workflow (`roundtrip-samples.yml`) for automated roundtrip testing against live mn-samples sites
- `tasks/roundtrip_samples.rake` with flavor-to-model mapping and consolidated reporting
- Inline element models: LaTeX math, strike, underline, localized strings, formatted footnotes
- Missing XML attribute mappings: `ol@start`, `subdivision name@language`, `docidentifier@language`
- Mixed content and nested link support in inline elements

### Fixed

- `Moxml::Adapter::Nokogiri.children` override accepts the `entity_bearing:` keyword of moxml 0.5.36 and later (#66)
- Roundtrip fidelity: missing attributes, model corrections, and Canon config alignment
- Stale `Semantic::Root` reference in rake task

## [0.1.0] - 2022-03-11

- Initial release
