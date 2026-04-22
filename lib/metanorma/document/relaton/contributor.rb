# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # The contributor involved in the production of a bibliographic item; may be either a person or an
      # organization.
      class Contributor < Lutaml::Model::Serializable
        xml do
          element "contributor"
        end
      end
    end
  end
end
