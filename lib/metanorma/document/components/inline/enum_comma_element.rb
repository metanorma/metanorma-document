# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        class EnumCommaElement < Lutaml::Model::Serializable
          attribute :text, :string

          xml do
            element "enum-comma"
            map_content to: :text
          end
        end
      end
    end
  end
end
