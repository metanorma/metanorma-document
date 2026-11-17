# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Blocks
        # <component> of a requirement model (Statement / Guidance / …).
        class RequirementComponent < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :class_attr, :string
          attribute :p, Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                    collection: true
          attribute :ul, Metanorma::Document::Components::Lists::UnorderedList,
                    collection: true
          attribute :ol, Metanorma::Document::Components::Lists::OrderedList,
                    collection: true
          attribute :sourcecode,
                    Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock,
                    collection: true
          attribute :table, Metanorma::Document::Components::Tables::TableBlock,
                    collection: true
          attribute :example,
                    Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
                    collection: true
          attribute :note, Metanorma::Document::Components::Blocks::NoteBlock,
                    collection: true
          attribute :figure,
                    Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
                    collection: true

          xml do
            element "component"
            map_attribute "id", to: :id
            map_attribute "class", to: :class_attr
            map_element "p", to: :p
            map_element "ul", to: :ul
            map_element "ol", to: :ol
            map_element "sourcecode", to: :sourcecode
            map_element "table", to: :table
            map_element "example", to: :example
            map_element "note", to: :note
            map_element "figure", to: :figure
          end
        end
      end
    end
  end
end
