# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Elements
      # Indication of text deleted through editorial intervention.
      class Del < Metanorma::Document::Components::TextElements::TextElement
        attribute :semx_id, :string
        attribute :original_id, :string
        xml do
          element "del"

          map_attribute "semx-id", to: :semx_id
          map_attribute "original-id", to: :original_id
        end
      end
    end
  end
end
