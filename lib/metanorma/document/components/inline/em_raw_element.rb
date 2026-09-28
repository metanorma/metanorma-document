# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Emphasised raw text: accepts the full inline vocabulary as
        # children (footnotes, links, nested formatting, math) so no
        # inline payload inside <em> is dropped at parse time.
        class EmRawElement < Lutaml::Model::Serializable
          include Metanorma::Document::Components::Inline::Vocabulary

          xml do
            element "em"
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
