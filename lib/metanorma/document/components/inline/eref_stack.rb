# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Set of cross-references to bibliographic references,
        # joined with connectives.
        class ErefStack < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :eref, Metanorma::Document::Components::Inline::ErefElement,
                    collection: true

          xml do
            element "erefstack"
            map_attribute "id", to: :id
            map_element "eref", to: :eref
          end
        end
      end
    end
  end
end
