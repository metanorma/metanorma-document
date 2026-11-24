# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        class SmallCapElement < Lutaml::Model::Serializable
          include Vocabulary

          attribute :text, :string, collection: true

          xml do
            element "smallcap"
            mixed_content
            map_content to: :text
            VocabularyXmlMapping.apply_inline_mappings(self)
          end
        end
      end
    end
  end
end
