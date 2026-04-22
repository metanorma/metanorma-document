# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module AncillaryBlocks
      # Block containing computer code or comparable text.
      class SourcecodeBlock < Metanorma::BasicDocument::Blocks::BasicBlockNoNotes
        # The caption of the block.
        attribute :name, Metanorma::BasicDocument::TextElements::TextElement,
                  collection: true

        # The block should be excluded from any automatic numbering of blocks of this class in the document.
        attribute :unnumbered, :boolean

        # Define a subsequence for numbering of this block; e.g. if this block would be numbered
        # as 7, but it has a subsequence value of XYZ, this block, and all consecutive blocks
        # of the same class and with the same subsequence value, will be numbered consecutively
        # with the same number and in a subsequence: 7a, 7b, 7c etc.
        attribute :subsequence, :string

        # A file name associated with the source code (and which could be used to extract the source code
        # fragment to from the document, or to populate the source code fragment with from the external file,
        # in automated processing of the document).
        attribute :filename, :string

        # The computer language or other notational convention that the source code is expressed in.
        attribute :lang, :string

        # The computer code or other such text presented in the block, as a single unformatted string. (The
        # string should be treated as pre-formatted text, with whitespace treated as significant.)
        attribute :content, :string

        # Zero or more cross-references; these are intended to be embedded within the `content` string, and
        # link to annotations.
        attribute :callouts,
                  Metanorma::BasicDocument::ReferenceElements::ReferenceToIdElement, collection: true

        # Annotations to the source code; each annotation consists of zero or more paragraphs, and is intended
        # to be referenced by a callout within the source code.
        attribute :callout_annotations,
                  Metanorma::BasicDocument::Paragraphs::ParagraphBlock, collection: true

        xml do
          element "sourcecode"
          map_element "name", to: :name
          map_attribute "unnumbered", to: :unnumbered
          map_attribute "subsequence", to: :subsequence
          map_attribute "filename", to: :filename
          map_attribute "lang", to: :lang
          map_content to: :content
          map_element "callouts", to: :callouts
          map_element "callout-annotations", to: :callout_annotations
        end
      end
    end
  end
end
