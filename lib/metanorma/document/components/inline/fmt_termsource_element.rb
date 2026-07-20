# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        class FmtTermsourceElement < Lutaml::Model::Serializable
          include RenderedDisplay
          include Inline::Vocabulary

          attribute :status, :string
          attribute :type, :string

          xml do
            element "fmt-termsource"
            mixed_content
            map_attribute "status", to: :status
            map_attribute "type", to: :type
            map_content to: :text
            Vocabulary::VocabularyXmlMapping.apply_inline_mappings(self)
          end
        end
      end
    end
  end
end
