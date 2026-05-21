# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Blocks
        class Passthrough < BasicBlockNoNotes
          attribute :formats, :string
          attribute :content, :string

          xml do
            element "passthrough"
            map_attribute "id", to: :id
            map_attribute "formats", to: :formats
            map_content to: :content
          end
        end
      end
    end
  end
end
