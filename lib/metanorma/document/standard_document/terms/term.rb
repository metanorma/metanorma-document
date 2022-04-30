# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # A term (`Term`) represents a terminology entry with
  # its definition.
  #
  # NOTE: The `Term` definition fully aligns with the structure
  # and requirements of terms in ISO/IEC DIR 2, 16.6.
  class Term < Core::Node
    include Core::Node::Custom

    register_element "term" do
      # The language of the term entry, as an ISO-639 3-letter code.
      attribute :language, BasicDocument::Iso639Code

      # The script of the term entry, as an ISO-15924 code.
      attribute :script, BasicDocument::Iso15924Code

      # Non-unique identifier within document. Used to align two blocks in different languages in a
      # multilingual document.
      attribute :tag, String

      # Specification of how a block element may be rendered in a multilingual document.
      attribute :multilingual_rendering, MultilingualRenderingType

      # An optional identifier for the term, to be used in
      # cross-references.
      attribute :id, String

      # One or more names under which the term being defined
      # is canonically known.
      nodes :preferred, Designation

      # Zero or more names which are acceptable synonyms for
      # the term being defined.
      nodes :admitted, Designation

      # Zero or more names which are related to the term being
      # defined. Each has a type, indicating how the term is related;
      # permitted values are compare (for "see also" references to terms),
      # contrast (for terms that illuminate the term definition as what it
      # is not), see (if this is a deprecated term, to reference the
      # preferred term)
      nodes :related, RelatedTerm

      # Zero or more names which are deprecated synonyms for
      # the term being defined.
      nodes :deprecates, Designation

      # An optional semantic domain for the term being defined,
      # in case the term is ambiguous between several semantic domains.
      node :domain, BasicDocument::LocalizedString

      # Subject of the term.
      node :subject, BasicDocument::LocalizedString

      # Information about how the term is to be used.
      nodes :usage_info, BasicDocument::BasicBlock

      # The definition of the term applied in the current
      # document.
      nodes :definition, TermDefinition

      # Zero or more notes about the term.
      nodes :note, BasicDocument::ParagraphBlock

      # Zero or more examples of how the term is to be used.
      nodes :example, BasicDocument::ParagraphBlock

      # Zero or more bibliographical sources for the term. These
      # include the `origin` of the term, which is its bibliographical
      # citation (as defined in Relaton); the `status` of the
      # definition (whether `identical` to the definition given in the
      # origin cited, or `modified`); and, if the definition is modified, a
      # description of the `modification` to the definition applied for
      # this document.
      nodes :source, TermSource
    end
  end
end; end; end
