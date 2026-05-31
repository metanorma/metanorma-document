# 01 — Split multi-class files into one-class-per-file — DONE

All model files now contain exactly one class per file. Verified: every file under `lib/metanorma/document/`, `lib/metanorma/standard_document/`, `lib/metanorma/iso_document/`, `lib/metanorma/bipm_document/`, `lib/metanorma/itu_document/`, `lib/metanorma/ietf_document/`, `lib/metanorma/cc_document/` is single-class.

Nested classes that are only used internally by their parent (e.g. `AnnotationContainer::Annotation`) are legitimate and NOT split.

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
