# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module ContribMetadata
        # Digital signature.
        class Signature < IntegrityValue
          attribute :algorithm, :string
          attribute :public_key, :string
          attribute :signature, :string

          xml do
            element "signature"
            map_attribute "algorithm", to: :algorithm
            map_attribute "public-key", to: :public_key
            map_content to: :signature
          end
        end
      end
    end
  end
end
