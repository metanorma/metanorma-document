# frozen_string_literal: true

require_relative "../inline/fmt_ladl_label_data"

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        # A figure embedded within another figure.
        # Subfigures only occur within figures.
        class Subfigure < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :anchor, :string
          attribute :name, Metanorma::Document::Components::Inline::NameWithIdElement
          attribute :image, Metanorma::Document::Components::IdElements::Image
          attribute :figure, Subfigure, collection: true
          attribute :key, :string
          attribute :dl, Metanorma::Document::Components::Lists::DefinitionList
          attribute :semx_id, :string
          attribute :autonum, :string
          attribute :fmt_name, Metanorma::Document::Components::Inline::FmtNameElement
          attribute :fmt_xref_label,
                    Metanorma::Document::Components::Inline::FmtXrefLabelElement, collection: true

          attribute :hidden, :boolean
          attribute :fmt_ladl_label_data,
                    Metanorma::Document::Components::Inline::FmtLadlLabelData

          xml do
            map_attribute "hidden", to: :hidden
            map_element "fmt-ladl-label-data", to: :fmt_ladl_label_data
            element "figure"
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_attribute "semx-id", to: :semx_id
            map_attribute "autonum", to: :autonum
            map_element "name", to: :name
            map_element "image", to: :image
            map_element "figure", to: :figure
            map_element "key", to: :key
            map_element "dl", to: :dl
            map_element "fmt-name", to: :fmt_name
            map_element "fmt-xref-label", to: :fmt_xref_label
          end
        end
      end
    end
  end
end
