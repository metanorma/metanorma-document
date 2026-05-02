# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Blocks
      class NoteBlock < Metanorma::BasicDocument::Blocks::BasicBlockNoNotes
        xml do
          element "note"
        end
      end
    end
  end
end
