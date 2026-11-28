# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        class FmtXrefElement < Lutaml::Model::Serializable
          include RenderedDisplay
          include Inline::Vocabulary

          attribute :target, :string
          attribute :type, :string

          xml do
            element "fmt-xref"
            mixed_content
            map_attribute "target", to: :target
            map_attribute "type", to: :type
            map_content to: :text
            VocabularyXmlMapping.apply_inline_mappings(self)
          end
        end
      end
    end
  end
end
