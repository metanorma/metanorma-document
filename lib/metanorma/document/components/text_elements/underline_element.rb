# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Underlined text. Corresponds to HTML 4 `u`.
        # Contains mixed content with inline elements.
        class UnderlineElement < Lutaml::Model::Serializable
          include Inline::Vocabulary
          attribute :text, :string, collection: true
          attribute :ruby, "Metanorma::Document::Components::TextElements::RubyElement",
                    collection: true

          xml do
            element "underline"
            mixed_content
            map_content to: :text
            Metanorma::Document::Components::Inline::Vocabulary::VocabularyXmlMapping.apply_inline_mappings(self)
          end
        end
      end
    end
  end
end
