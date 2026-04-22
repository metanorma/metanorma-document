# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module ContribMetadata
        # Hash value for a digital signature.
        class Hash < IntegrityValue
          attribute :algorithm, :string
          attribute :value, :string

          xml do
            element "hash"
            map_attribute "algorithm", to: :algorithm
            map_content to: :value
          end
        end
      end
    end
  end
end
