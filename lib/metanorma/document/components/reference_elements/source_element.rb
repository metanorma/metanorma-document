# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module ReferenceElements
        class SourceElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :status, :string
          attribute :type, :string
          attribute :origin, SourceOrigin
          attribute :modification, SourceModification
          attribute :fmt_source,
                    "Metanorma::Document::Components::Inline::FmtSourceElement",
                    collection: true

          xml do
            element "source"
            map_attribute "id", to: :id
            map_attribute "status", to: :status
            map_attribute "type", to: :type
            map_element "origin", to: :origin
            map_element "modification", to: :modification
            map_element "fmt-source", to: :fmt_source
          end
        end
      end
    end
  end
end
