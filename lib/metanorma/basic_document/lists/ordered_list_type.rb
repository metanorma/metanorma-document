# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Lists
      # Type of numbering applied to the list items in an ordered list.
      class OrderedListType < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "ordered-list-type"
          map_content to: :value
        end

        def self.values
          %w[roman alphabet arabic romanUpper alphabetUpper]
        end
      end
    end
  end
end
