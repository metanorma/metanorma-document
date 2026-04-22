# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Code for currencies, as specified in <<iso4217>>.
      class Iso4217Code < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "iso4217-code"
          map_content to: :value
        end
      end
    end
  end
end
