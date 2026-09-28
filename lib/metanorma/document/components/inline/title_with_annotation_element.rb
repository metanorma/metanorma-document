# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        class TitleWithAnnotationElement < Lutaml::Model::Serializable
          include Metanorma::Document::Components::Inline::Vocabulary

          attribute :id, :string
          attribute :anchor, :string
          attribute :semx_id, :string
          attribute :fmt_annotation_end, FmtAnnotationBodyElement

          xml do
            element "title"
            mixed_content
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_attribute "semx-id", to: :semx_id
            map_content to: :text
            map_element "fmt-annotation-end", to: :fmt_annotation_end

            # Titles carry the full inline vocabulary (footnotes on
            # clause titles, formatted links, math); including the
            # shared vocabulary keeps every child at parse time.
            Metanorma::Document::Components::Inline::Vocabulary::VocabularyXmlMapping
              .apply_inline_mappings(self)
          end
        end
      end
    end
  end
end
