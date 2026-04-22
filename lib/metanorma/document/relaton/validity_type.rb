# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # The time interval for which a bibliographic item
      # is determined valid, and the associated revision date.
      class ValidityType < Lutaml::Model::Serializable
        attribute :validity_begins, :string
        attribute :validity_ends, :string
        attribute :revision, :string

        xml do
          element "validity"
          map_element "validityBegins", to: :validity_begins
          map_element "validityEnds", to: :validity_ends
          map_element "revision", to: :revision
        end
      end
    end
  end
end
