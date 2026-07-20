# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # A variant name of an organization.
      # Keep-forever (wave-5 sweep): relaton-bib 2.2.0.pre.alpha.1 inlines
      # variant name fields and has no variant wrapper class; not a migration
      # candidate.
      class VariantOrgName < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :content, Metanorma::Document::Components::DataTypes::LocalizedString

        xml do
          map_attribute "type", to: :type
          map_element "content", to: :content
        end
      end
    end
  end
end
