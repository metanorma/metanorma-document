# frozen_string_literal: true

module Metanorma
  module NistDocument
    module Sections
      class ErrataRow < Lutaml::Model::Serializable
        attribute :date, :string
        attribute :type, :string
        attribute :change, :string, collection: true
        attribute :pages, :string

        xml do
          element "row"
          map_element "date",   to: :date
          map_element "type",   to: :type
          map_element "change", to: :change
          map_element "pages",  to: :pages
        end
      end
    end
  end
end
