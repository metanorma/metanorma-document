# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Strongly emphasised raw text: accepts the full inline
        # vocabulary as children so no inline payload inside <strong>
        # is dropped at parse time.
        class StrongRawElement < Lutaml::Model::Serializable
          include Metanorma::Document::Components::Inline::Vocabulary

          xml do
            element "strong"
            mixed_content
            map_content to: :text
            Metanorma::Document::Components::Inline::Vocabulary::VocabularyXmlMapping
              .apply_inline_mappings(self)
          end
        end
      end
    end
  end
end
