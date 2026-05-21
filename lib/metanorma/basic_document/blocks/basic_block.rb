# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Blocks
      class BasicBlock < Metanorma::BasicDocument::Blocks::BasicBlockNoNotes
        attribute :notes, "Metanorma::BasicDocument::Blocks::NoteBlock",
                  collection: true

        xml do
          element "basic-block"
          map_element "notes", to: :notes
        end
      end
    end
  end
end
