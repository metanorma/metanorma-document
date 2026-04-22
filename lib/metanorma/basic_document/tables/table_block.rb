# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Tables
      # Tabular arrangement of text
      class TableBlock < Metanorma::BasicDocument::Blocks::BasicBlock
        attribute :name, Metanorma::BasicDocument::TextElements::TextElement,
                  collection: true
        attribute :unnumbered, :boolean
        attribute :subsequence, :string
        attribute :alt, :string
        attribute :summary, :string
        attribute :uri, :string
        attribute :head, Metanorma::BasicDocument::Tables::TextTableRow
        attribute :body, Metanorma::BasicDocument::Tables::TextTableRow,
                  collection: true
        attribute :foot, Metanorma::BasicDocument::Tables::TextTableRow
        attribute :definitions, Metanorma::BasicDocument::Lists::DefinitionList

        xml do
          element "table"
          map_element "name", to: :name
          map_attribute "unnumbered", to: :unnumbered
          map_attribute "subsequence", to: :subsequence
          map_attribute "alt", to: :alt
          map_attribute "summary", to: :summary
          map_attribute "uri", to: :uri
          map_element "head", to: :head
          map_element "body", to: :body
          map_element "foot", to: :foot
          map_element "definitions", to: :definitions
        end
      end
    end
  end
end
