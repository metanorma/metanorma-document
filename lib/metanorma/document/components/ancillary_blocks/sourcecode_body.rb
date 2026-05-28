# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        class SourcecodeBody < Lutaml::Model::Serializable
          attribute :content, :string

          xml do
            element "body"
            map_all_content to: :content
          end
        end
      end
    end
  end
end
