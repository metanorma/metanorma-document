# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Lists
        # List item inside an ordered or unordered list.
        # Contains text content.
        class ListItem < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :anchor, :string
          attribute :semx_id, :string
          attribute :original_id, :string
          attribute :text, "Metanorma::Document::Components::TextElements::TextElement",
                    collection: true
          attribute :content_text, :string, collection: true
          attribute :paragraphs, "Metanorma::Document::Components::Paragraphs::ParagraphBlock",
                    collection: true
          attribute :formula,
                    "Metanorma::Document::Components::AncillaryBlocks::FormulaBlock",
                    collection: true
          attribute :figure,
                    "Metanorma::Document::Components::AncillaryBlocks::FigureBlock",
                    collection: true
          attribute :unordered_lists,
                    UnorderedList,
                    collection: true
          attribute :ordered_lists,
                    OrderedList,
                    collection: true
          attribute :sourcecode,
                    "Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock",
                    collection: true
          attribute :dl,
                    "Metanorma::Document::Components::Lists::DefinitionList"
          attribute :example,
                    "Metanorma::Document::Components::AncillaryBlocks::ExampleBlock",
                    collection: true
          attribute :note,
                    "Metanorma::Document::Components::Blocks::NoteBlock",
                    collection: true
          attribute :quote,
                    "Metanorma::Document::Components::MultiParagraph::QuoteBlock",
                    collection: true
          attribute :table,
                    "Metanorma::Document::Components::Tables::TableBlock",
                    collection: true
          attribute :fmt_name, "Metanorma::Document::Components::Inline::FmtNameElement"
          attribute :checkedcheckbox, :string
          attribute :uncheckedcheckbox, :string
          attribute :label, :string
          attribute :json_text, :string

          xml do
            element "li"
            mixed_content
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_attribute "semx-id", to: :semx_id
            map_attribute "original-id", to: :original_id
            map_attribute "checkedcheckbox", to: :checkedcheckbox
            map_attribute "uncheckedcheckbox", to: :uncheckedcheckbox
            map_attribute "label", to: :label
            map_content to: :content_text
            map_element "text", to: :text
            map_element "p", to: :paragraphs
            map_element "formula", to: :formula
            map_element "figure", to: :figure
            map_element "sourcecode", to: :sourcecode
            map_element "dl", to: :dl
            map_element "example", to: :example
            map_element "note", to: :note
            map_element "quote", to: :quote
            map_element "table", to: :table
            map_element "ul", to: :unordered_lists
            map_element "ol", to: :ordered_lists
            map_element "fmt-name", to: :fmt_name
          end

          json do
            map "text", to: :json_text
          end

          def json_text
            if paragraphs && !paragraphs.empty?
              return paragraphs.map { |p| p.text || "" }.join(" ").strip
            end

            ct = content_text
            if ct.is_a?(Array) && !ct.empty?
              return ct.compact.join.strip
            end

            text&.filter_map do |t|
              t.respond_to?(:text) ? t.text : t.to_s
            end&.join
          end
        end
      end
    end
  end
end
