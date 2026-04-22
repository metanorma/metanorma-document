# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        # Block containing a figure: a visual rather than textual asset, possibly with accompanying text.
        class FigureBlock < Metanorma::Document::Components::Blocks::BasicBlockNoNotes
          # A URI or other reference intended to link to an externally hosted image (or equivalent).
          attribute :source, :string

          # The block should be excluded from any automatic numbering of blocks of this class in the document.
          attribute :unnumbered, :boolean

          # Define a subsequence for numbering of this block; e.g. if this block would be numbered
          # as 7, but it has a subsequence value of XYZ, this block, and all consecutive blocks
          # of the same class and with the same subsequence value, will be numbered consecutively
          # with the same number and in a subsequence: 7a, 7b, 7c etc.
          attribute :subsequence, :string

          # The caption of the block.
          attribute :name, Metanorma::Document::Components::Inline::NameWithIdElement

          # The semantic category of the figure. This is to allow different classes of figure (e.g. _Plate_,
          # _Chart_, _Diagram_) to be auto-numbered and captioned differently.
          attribute :figure_class, :string

          attribute :anchor, :string
          attribute :semx_id, :string
          attribute :autonum, :string
          attribute :displayorder, :integer
          attribute :height, :string
          attribute :width, :string

          # The image file to be included in the figure as its main content.
          attribute :image, Metanorma::Document::Components::IdElements::Image

          # The video file to be included in the figure as its main content.
          attribute :video, Metanorma::Document::Components::IdElements::Video

          # The audio file to be included in the figure as its main content.
          attribute :audio, Metanorma::Document::Components::IdElements::Audio

          # Figures embedded within the main figure.
          attribute :figure,
                    Metanorma::Document::Components::AncillaryBlocks::Subfigure, collection: true

          # An optional definitions list defining any symbols used in the figure.
          attribute :dl, Metanorma::Document::Components::Lists::DefinitionList

          # Key definitions for figure
          attribute :key, KeyElement

          # Optional footnotes specific to the figure.
          attribute :footnotes, Metanorma::Document::Components::Inline::FnElement,
                    collection: true

          # Notes attached to the figure.
          attribute :note, Metanorma::Document::Components::Blocks::NoteBlock,
                    collection: true

          # Presentation-specific elements
          attribute :fmt_name, Metanorma::Document::Components::Inline::FmtNameElement
          attribute :fmt_xref_label,
                    Metanorma::Document::Components::Inline::FmtXrefLabelElement, collection: true

          attribute :json_type, :string

          def json_type
            "figure"
          end

          json do
            map "type", to: :json_type
            map "id", to: :id
            map "image", to: :image
            map "name", to: :name
          end

          xml do
            element "figure"
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_attribute "semx-id", to: :semx_id
            map_attribute "autonum", to: :autonum
            map_attribute "displayorder", to: :displayorder
            map_attribute "height", to: :height
            map_attribute "width", to: :width, render_empty: true
            map_attribute "source", to: :source
            map_attribute "unnumbered", to: :unnumbered
            map_attribute "subsequence", to: :subsequence
            map_element "name", to: :name
            map_attribute "class", to: :figure_class
            map_element "image", to: :image
            map_element "video", to: :video
            map_element "audio", to: :audio
            map_element "figure", to: :figure
            map_element "dl", to: :dl
            map_element "key", to: :key
            map_element "fn", to: :footnotes
            map_element "note", to: :note
            map_element "fmt-name", to: :fmt_name
            map_element "fmt-xref-label", to: :fmt_xref_label
          end
        end
      end
    end
  end
end
