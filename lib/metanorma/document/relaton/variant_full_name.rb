# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # A variant name of a person.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 inlines the name
      # fields under variant; ours wraps a FullName in content (no fixture
      # coverage justifies a shape change).
      class VariantFullName < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :content, Metanorma::Document::Relaton::FullName

        xml do
          map_attribute "type", to: :type
          map_element "content", to: :content
        end
      end
    end
  end
end
