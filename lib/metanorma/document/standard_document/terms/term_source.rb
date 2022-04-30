# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # The bibliographic source where a term is defined in the
  # sense applicable in this _StandardDocument_.
  class TermSource < Core::Node
    include Core::Node::Custom

    register_element do
      # The status of the term as it is used in this document,
      # relative to its definition in the original document.
      attribute :status, TermSourceStatus

      # The type of the managed term in the present context.
      attribute :status, TermSourceType

      # The original document and location where the term definition has been obtained from.
      node :origin, BasicDocument::Citation

      # Any changes that the definition of the term has undergone relative to the original document,
      # in order to be applicable in this _StandardDocument_.
      node :modification, BasicDocument::ParagraphBlock
    end
  end
end; end; end
