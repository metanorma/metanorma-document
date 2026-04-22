# frozen_string_literal: true

module Metanorma
  module IsoDocument
    # Paragraph with mixed inline content preserved as raw XML.
    # Used for contexts where <p> contains inline elements like
    # <concept>, <xref>, <em>, <strong>, <stem>, <fn>, <link>.
    class RawParagraph < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :semx_id, :string
      attribute :original_id, :string
      attribute :content, :string

      xml do
        element "p"
        map_attribute "id", to: :id
        map_attribute "semx-id", to: :semx_id
        map_attribute "original-id", to: :original_id
        map_all_content to: :content
      end
    end
  end
end
