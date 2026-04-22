# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module ContribMetadata
      # A digital signature of the contribution, consisting of a `hash` value and a `signature`, with an
      # associated `publicKey`.
      class IntegrityValue < Lutaml::Model::Serializable
        xml do
          element "integrity-value"
        end
      end
    end
  end
end
