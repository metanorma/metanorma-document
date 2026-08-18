# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Generator-only error message carried in place of an unresolved
        # concept or related-term cross-reference.
        class ErrorMessage < Lutaml::Model::Serializable
          include Metanorma::Document::Components::Inline::Vocabulary

          attribute :index_xref,
                    Metanorma::Document::Components::EmptyElements::IndexElement,
                    collection: true

          xml do
            element "errormsg"
            mixed_content
            map_content to: :text
            map_element "index-xref", to: :index_xref
            Metanorma::Document::Components::Inline::Vocabulary::VocabularyXmlMapping
              .apply_inline_mappings(self)
          end
        end
      end
    end
  end
end
