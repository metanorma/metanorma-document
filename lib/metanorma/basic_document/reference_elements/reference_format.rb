# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module ReferenceElements
      # The type of Reference Element, prescribing how it is to be rendered.
      class ReferenceFormat < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "reference-format"
          map_content to: :value
        end

        def self.values
          %w[external inline footnote callout]
        end
      end
    end
  end
end
