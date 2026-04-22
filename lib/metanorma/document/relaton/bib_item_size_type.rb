# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Type of size of a bibliographic item.
      class BibItemSizeType < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "bib-item-size-type"
          map_content to: :value
        end

        def self.values
          %w[page volume time data value]
        end
      end
    end
  end
end
