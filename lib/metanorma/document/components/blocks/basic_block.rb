# frozen_string_literal: true

require_relative "../inline/fmt_ladl_label_data"

module Metanorma
  module Document
    module Components
      module Blocks
        # Block of textual content in BasicDocument.
        class BasicBlock < Lutaml::Model::Serializable
          attribute :notes, NoteBlock, collection: true

          attribute :fmt_ladl_label_data, Metanorma::Document::Components::Inline::FmtLadlLabelData

          xml do
            map_element "fmt-ladl-label-data", to: :fmt_ladl_label_data
            element "basic-block"
            map_element "notes", to: :notes
          end
        end
      end
    end
  end
end
