# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        # Rendered counterpart of `<figure>`: the presentation-layer
        # figure container. The overlay allows arbitrary rendered
        # blocks; the model carries the figure-rendering vocabulary
        # (caption, image, notes, examples) that presentation XML
        # emits.
        class FmtFigureElement < Lutaml::Model::Serializable
          include Metanorma::Document::Components::Inline::RenderedDisplay

          attribute :id, :string
          attribute :anchor, :string
          attribute :semx_id, :string
          attribute :name, Metanorma::Document::Components::Inline::NameWithIdElement
          attribute :image, Metanorma::Document::Components::IdElements::Image
          attribute :note, Metanorma::Document::Components::Blocks::NoteBlock,
                    collection: true
          attribute :example,
                    Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
                    collection: true
          attribute :text, :string, collection: true
          attribute :semx,
                    Metanorma::Document::Components::Inline::SemxElement,
                    collection: true

          xml do
            element "fmt-figure"
            mixed_content
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_attribute "semx-id", to: :semx_id
            map_element "name", to: :name
            map_element "image", to: :image
            map_element "note", to: :note
            map_element "example", to: :example
            map_content to: :text
            map_element "semx", to: :semx
          end
        end
      end
    end
  end
end
