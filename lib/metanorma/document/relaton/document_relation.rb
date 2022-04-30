# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Relation between a bibliographic item and another bibliographic item.
  class DocumentRelation < Core::Node
    include Core::Node::Custom

    register_element do
      # The type of document relation described, using a controlled vocabulary.
      attribute :type, DocumentRelationType

      # A more complete description of the type of document relation described.
      nodes :description, BasicDocument::FormattedString

      # The target bibliographic item to which this bibliographic item is described as related to.
      node :bibitem, BasicDocument::BibliographicItem

      # The extent of the target bibliographic item which is related to this bibliographic item,
      # provided that it is not the entire bibliographic item that is so related.
      nodes :bib_locality, LocalityStack

      # The extent of this bibliographic item which is related to the target bibliographic item,
      # provided that it is not the entire bibliographic item that is so related.
      nodes :bib_source_locality, LocalityStack
    end
  end
end; end; end
