# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Blocks
        class RequirementInherit < Lutaml::Model::Serializable
          attribute :text, :string, collection: true
          attribute :eref, Metanorma::Document::Components::Inline::ErefElement,
                    collection: true
          attribute :xref, Metanorma::Document::Components::Inline::XrefElement,
                    collection: true

          xml do
            mixed_content
            map_content to: :text
            map_element "eref", to: :eref
            map_element "xref", to: :xref
          end
        end
      end
    end
  end
end
