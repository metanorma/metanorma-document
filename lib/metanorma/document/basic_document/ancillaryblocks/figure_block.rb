# frozen_string_literal: true

require "metanorma/document/basic_document/blocks/basic_block_no_notes"

module Metanorma; module Document; module BasicDocument
  # Block containing a figure: a visual rather than textual asset, possibly with accompanying text.
  class FigureBlock < BasicBlockNoNotes
    register_element "figure" do
      # A URI or other reference intended to link to an externally hosted image (or equivalent).
      attribute :source, String

      # The block should be excluded from any automatic numbering of blocks of this class in the document.
      attribute :unnumbered, TrueClass

      # Define a subsequence for numbering of this block; e.g. if this block would be numbered
      # as 7, but it has a subsequence value of XYZ, this block, and all consecutive blocks
      # of the same class and with the same subsequence value, will be numbered consecutively
      # with the same number and in a subsequence: 7a, 7b, 7c etc.
      attribute :subsequence, String

      # The caption of the block.
      nodes :name, TextElement

      # The semantic category of the figure. This is to allow different classes of figure (e.g. _Plate_,
      # _Chart_, _Diagram_) to be auto-numbered and captioned differently.
      attribute :class, String # LocalizedString?

      # The image file to be included in the figure as its main content.
      node :image, Image

      # The video file to be included in the figure as its main content.
      node :video, Video

      # The audio file to be included in the figure as its main content.
      node :audio, Audio

      # Figures embedded within the main figure.
      nodes :figure, Subfigure

      # An optional definitions list defining any symbols used in the figure.
      node :definitions, DefinitionList

      # Optional footnotes specific to the figure.
      nodes :footnotes, BasicObject # But actually: ReferenceToldWithParagraphElement
    end
  end
end; end; end
