# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Change
        # Identifier used to uniquely identify a BasicDocument.
        class UniqueIdentifier < Lutaml::Model::Serializable
          attribute :value, :string

          xml do
            element "unique-identifier"
            map_content to: :value
          end
        end
      end
    end
  end
end
