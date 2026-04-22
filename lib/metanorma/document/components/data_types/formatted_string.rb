# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module DataTypes
        # String which is formatted according to conventions specified
        # in a named MIME type (<<rfc2046>>).
        class FormattedString < Lutaml::Model::Serializable
          attribute :language, :string
          attribute :script, :string
          attribute :value, :string, collection: true
          attribute :type, :string
          attribute :format, :string
          attribute :abbreviation, :string
          attribute :semx, Metanorma::Document::Components::Inline::SemxElement,
                    collection: true
          attribute :span, Metanorma::Document::Components::Inline::SpanElement,
                    collection: true
          attribute :em, Metanorma::Document::Components::Inline::EmRawElement,
                    collection: true
          attribute :strong, Metanorma::Document::Components::Inline::StrongRawElement,
                    collection: true
          attribute :smallcap, Metanorma::Document::Components::Inline::SmallCapElement,
                    collection: true
          attribute :link, Metanorma::Document::Components::Inline::LinkElement,
                    collection: true
          attribute :br, Metanorma::Document::Components::Inline::BrElement,
                    collection: true
          attribute :p, Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                    collection: true
          attribute :sup, Metanorma::Document::Components::Inline::SupElement,
                    collection: true
          attribute :sub, Metanorma::Document::Components::Inline::SubElement,
                    collection: true
          attribute :fn, Metanorma::Document::Components::Inline::FnElement,
                    collection: true
          attribute :stem, Metanorma::Document::Components::Inline::StemInlineElement,
                    collection: true
          attribute :fmt_stem, Metanorma::Document::Components::Inline::FmtStemElement,
                    collection: true
          attribute :eref, Metanorma::Document::Components::Inline::ErefElement,
                    collection: true
          attribute :xref, Metanorma::Document::Components::Inline::XrefElement,
                    collection: true
          attribute :strike, Metanorma::Document::Components::TextElements::StrikeElement,
                    collection: true
          attribute :dl, Metanorma::Document::Components::Lists::DefinitionList
          attribute :ul, Metanorma::Document::Components::Lists::UnorderedList,
                    collection: true
          attribute :ol, Metanorma::Document::Components::Lists::OrderedList,
                    collection: true
          attribute :table, Metanorma::Document::Components::Tables::TableBlock,
                    collection: true
          attribute :tt, Metanorma::Document::Components::Inline::TtElement,
                    collection: true
          attribute :underline, Metanorma::Document::Components::TextElements::UnderlineElement,
                    collection: true

          xml do
            mixed_content
            map_attribute "language", to: :language
            map_attribute "script", to: :script
            map_attribute "type", to: :type
            map_attribute "format", to: :format
            map_attribute "abbreviation", to: :abbreviation
            map_content to: :value
            map_element "semx", to: :semx
            map_element "span", to: :span
            map_element "em", to: :em
            map_element "strong", to: :strong
            map_element "smallcap", to: :smallcap
            map_element "link", to: :link
            map_element "br", to: :br
            map_element "p", to: :p
            map_element "sup", to: :sup
            map_element "sub", to: :sub
            map_element "fn", to: :fn
            map_element "stem", to: :stem
            map_element "fmt-stem", to: :fmt_stem
            map_element "eref", to: :eref
            map_element "xref", to: :xref
            map_element "strike", to: :strike
            map_element "dl", to: :dl
            map_element "ul", to: :ul
            map_element "ol", to: :ol
            map_element "table", to: :table
            map_element "tt", to: :tt
            map_element "underline", to: :underline
          end
        end
      end
    end
  end
end
