# frozen_string_literal: true

require_relative "blocks/basic_block_no_notes"
require_relative "blocks/basic_block"
require_relative "blocks/note_block"

module Metanorma
  module BasicDocument
    module Blocks
    end
  end
end

Metanorma::BasicDocument::Blocks::BasicBlock.class_eval do
  attribute :notes, Metanorma::BasicDocument::Blocks::NoteBlock,
            collection: true

  xml do
    map_element "notes", to: :notes
  end
end

require_relative "paragraphs"

Metanorma::BasicDocument::Blocks::NoteBlock.class_eval do
  attribute :content,
            Metanorma::BasicDocument::Paragraphs::ParagraphBlock, collection: true

  xml do
    map_element "content", to: :content
  end
end
