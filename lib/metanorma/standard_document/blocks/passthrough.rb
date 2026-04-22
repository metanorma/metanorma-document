# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Blocks
      # Wrapper around raw markup to be transferred into one or more nominated output formats
      # during processing.
      class Passthrough < Metanorma::StandardDocument::Blocks::StandardBlockNoNotes
        attribute :formats, :string
        attribute :content, :string

        xml do
          element "passthrough"
          map_attribute "formats", to: :formats
          map_content to: :content
        end
      end
    end
  end
end
