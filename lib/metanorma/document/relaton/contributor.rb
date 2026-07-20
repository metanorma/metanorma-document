# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # The contributor involved in the production of a bibliographic item; may be either a person or an
      # organization.
      # Keep-forever (wave-5 sweep): internal base class for Organization and
      # the contributor-typed attributes — relaton-bib 2.2.0.pre.alpha.1
      # Contributor is a role+entity model, not this wrapper; not a migration
      # candidate.
      class Contributor < Lutaml::Model::Serializable
        xml do
          element "contributor"
        end
      end
    end
  end
end
