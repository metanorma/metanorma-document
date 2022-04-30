# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Content addressing legal and licensing concerns around the document,
  # outside of the main flow of document content.
  class BoilerplateType < Core::Node
    include Core::Node::Custom

    register_element do
      # Preset templated text provided by the standardization body,
      # describing the copyright status of the document.
      nodes :copyright, BasicDocument::HierarchicalSection

      # Preset templated text provided by the standardization body,
      # providing the licensing terms for the document content.
      nodes :license, BasicDocument::HierarchicalSection

      # Preset templated text provided by the standardization body,
      # providing the legal constraints and considerations around use of
      # the document.
      nodes :legal, BasicDocument::HierarchicalSection

      # Preset templated text provided by the standardization body,
      # providing information on where feedback on the document may be
      # addressed to.
      nodes :feedback, BasicDocument::HierarchicalSection
    end
  end
end; end; end
