# frozen_string_literal: true

require "basic_document/blocks/basic_block_no_notes"

module Metanorma; module Document; module BasicDocument
  # Block containing a figure: a visual rather than textual asset, possibly with accompanying text.
  class FigureBlock < BasicBlockNoNotes
    register_element do
      # A URI or other reference intended to link to an externally hosted image (or equivalent).
      nodes :source, String

      # The block should be excluded from any automatic numbering of blocks of this class in the document.
      nodes :unnumbered, TrueClass

      # Define a subsequence for numbering of this block; e.g. if this block would be numbered
      # as 7, but it has a subsequence value of XYZ, this block, and all consecutive blocks
      # of the same class and with the same subsequence value, will be numbered consecutively
      # with the same number and in a subsequence: 7a, 7b, 7c etc.
      nodes :subsequence, String

      # The caption of the block.
      nodes :name, TextElement

      # The semantic category of the figure. This is to allow different classes of figure (e.g. _Plate_,
      # _Chart_, _Diagram_) to be auto-numbered and captioned differently.
      nodes :class, LocalizedString

      # The image file to be included in the figure as its main content.
      nodes :image, Image

      # The video file to be included in the figure as its main content.
      nodes :video, Video

      # The audio file to be included in the figure as its main content.
      nodes :audio, Audio

      # Figures embedded within the main figure.
      nodes :figure, Subfigure

      # An optional definitions list defining any symbols used in the figure.
      nodes :definitions, DefinitionList

      # Optional footnotes specific to the figure.
      nodes :footnotes, BasicObject # But actually: ReferenceToldWithParagraphElement
    end
  end
end; end; end