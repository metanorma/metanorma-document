# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        class CommaElement < Lutaml::Model::Serializable
          attribute :text, :string

          xml do
            element "comma"
            map_content to: :text
          end
        end
      end
    end
  end
end
