# frozen_string_literal: true

module Metanorma; module Document; module IsoDocument
  # Main body of ISO/IEC document.
  class IsoSections < Core::Node
    include Core::Node::Custom

    register_element do
      # Notes applicable to the entire document (e.g. footnotes on title).
      nodes :note, BasicDocument::NoteBlock

      # Admonitions applicable to the entire document (appearing before the initial clause).
      nodes :admonition, BasicDocument::AdmonitionBlock

      # Terms & Definitions clause.
      nodes :terms, StandardDocument::TermsSection

      # Symbols & Abbreviated Terms clause.
      nodes :definitions, BasicObject # But actually: DefinitionsSection

      # Normal Clauses.
      nodes :clause, StandardDocument::ClauseSection
    end
  end
end; end; end
