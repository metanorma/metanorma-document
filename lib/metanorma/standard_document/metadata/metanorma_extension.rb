# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Metadata
      class MetanormaExtension < Lutaml::Model::Serializable
        attribute :content, :string

        xml do
          element "metanorma-extension"
          map_all_content to: :content
        end
      end
    end
  end
end
