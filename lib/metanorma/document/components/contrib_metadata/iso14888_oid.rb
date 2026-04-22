# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module ContribMetadata
        # Identifier of digital signature algorithm defined in ISO 14888.
        class Iso14888Oid < Lutaml::Model::Serializable
          attribute :value, :string

          xml do
            element "iso14888-oid"
            map_content to: :value
          end
        end
      end
    end
  end
end
