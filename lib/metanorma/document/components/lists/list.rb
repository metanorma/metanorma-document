# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Lists
        # List block.
        class List < Metanorma::Document::Components::Blocks::BasicBlock
          attribute :listitem, "Metanorma::Document::Components::Lists::ListItem",
                    collection: true
          attribute :note,
                    Metanorma::Document::Components::Blocks::NoteBlock, collection: true
          attribute :id, :string

          xml do
            element "list"
            map_attribute "id", to: :id
            map_element "li", to: :listitem
            map_element "note", to: :note
          end
        end
      end
    end
  end
end
