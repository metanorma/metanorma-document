# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        class SourcecodeBlock < Metanorma::Document::Components::Blocks::BasicBlockNoNotes
          attribute :name, Metanorma::Document::Components::Inline::NameWithIdElement
          attribute :unnumbered, :boolean
          attribute :anchor, :string
          attribute :subsequence, :string
          attribute :filename, :string
          attribute :lang, :string
          attribute :markers, :string
          attribute :alt, :string
          attribute :content, :string
          attribute :body, SourcecodeBody
          attribute :callouts,
                    Metanorma::Document::Components::ReferenceElements::ReferenceToIdElement, collection: true
          attribute :callout_annotations,
                    CalloutAnnotation, collection: true
          attribute :fmt_sourcecode, Metanorma::Document::Components::Inline::FmtSourcecodeElement
          attribute :semx_id, :string
          attribute :json_type, :string

          def json_type
            "sourcecode"
          end

          json do
            map "type", to: :json_type
            map "id", to: :id
            map "content", to: :content
            map "filename", to: :filename
            map "lang", to: :lang
          end

          xml do
            element "sourcecode"
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_element "name", to: :name
            map_attribute "unnumbered", to: :unnumbered
            map_attribute "subsequence", to: :subsequence
            map_attribute "filename", to: :filename
            map_attribute "lang", to: :lang
            map_attribute "markers", to: :markers
            map_attribute "alt", to: :alt
            map_content to: :content
            map_element "body", to: :body
            map_element "callout", to: :callouts
            map_element "callout-annotation", to: :callout_annotations
            map_attribute "semx-id", to: :semx_id
            map_element "fmt-sourcecode", to: :fmt_sourcecode
          end
        end
      end
    end
  end
end
