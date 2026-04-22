# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module AncillaryBlocks
      # Block containing a figure: a visual rather than textual asset, possibly with accompanying text.
      class FigureBlock < Metanorma::BasicDocument::Blocks::BasicBlockNoNotes
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
        attribute :name, Metanorma::BasicDocument::TextElements::TextElement,
                  collection: true

        # The semantic category of the figure. This is to allow different classes of figure (e.g. _Plate_,
        # _Chart_, _Diagram_) to be auto-numbered and captioned differently.
        attribute :class, :string

        # The image file to be included in the figure as its main content.
        attribute :image, Metanorma::BasicDocument::IdElements::Image

        # The video file to be included in the figure as its main content.
        attribute :video, Metanorma::BasicDocument::IdElements::Video

        # The audio file to be included in the figure as its main content.
        attribute :audio, Metanorma::BasicDocument::IdElements::Audio

        # Figures embedded within the main figure.
        attribute :figure,
                  Metanorma::BasicDocument::AncillaryBlocks::Subfigure, collection: true

        # An optional definitions list defining any symbols used in the figure.
        attribute :definitions, Metanorma::BasicDocument::Lists::DefinitionList

        # Optional footnotes specific to the figure.
        attribute :footnotes, BasicObject, collection: true # But actually: ReferenceToldWithParagraphElement

        xml do
          element "figure"
          map_attribute "source", to: :source
          map_attribute "unnumbered", to: :unnumbered
          map_attribute "subsequence", to: :subsequence
          map_element "name", to: :name
          map_attribute "class", to: :class
          map_element "image", to: :image
          map_element "video", to: :video
          map_element "audio", to: :audio
          map_element "figure", to: :figure
          map_element "definitions", to: :definitions
          map_element "footnotes", to: :footnotes
        end
      end
    end
  end
end
