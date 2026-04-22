# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Sections
      # Colophon section in presentation XML.
      # Contains document control information.
      class Colophon < Lutaml::Model::Serializable
        attribute :clause, IsoClauseSection, collection: true

        xml do
          element "colophon"
          map_element "clause", to: :clause
        end
      end
    end
  end
end
