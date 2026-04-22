# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Blocks
      # Content block for amend description and new-content elements.
      # Uses map_all_content to preserve all children (p, ol, ul, table, etc.)
      class AmendContentBlock < Lutaml::Model::Serializable
        attribute :content, :string

        xml do
          map_all_content to: :content
        end
      end
    end
  end
end
