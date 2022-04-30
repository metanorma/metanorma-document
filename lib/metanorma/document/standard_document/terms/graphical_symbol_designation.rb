# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # A designation realised as a graphical symbol
  class GraphicalSymbolDesignation < Core::Node
    include Core::Node::Custom

    register_element "graphical-symbol" do
      # The textual form of the designation.
      node :figure, BasicDocument::FigureBlock

      # Whether the designation (typically an abbreviation) is the same across languages, or
      # language-specific.
      attribute :is_international, TrueClass, xml_attribute: "isInternational"
    end
  end
end; end; end
