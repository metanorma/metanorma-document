# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # A subdivision of an organization (e.g. committee, subcommittee, workgroup).
      class OrgSubdivision < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :subtype, :string
        attribute :name, LocalizedName, collection: true
        attribute :identifier, OrgSubdivisionIdentifier, collection: true
        attribute :fmt_identifier, Metanorma::Document::Components::Inline::FmtIdentifierElement,
                  collection: true
        attribute :logo, LogoElement

        xml do
          element "subdivision"
          map_attribute "type", to: :type
          map_attribute "subtype", to: :subtype, render_empty: true
          map_element "name", to: :name
          map_element "identifier", to: :identifier
          map_element "fmt-identifier", to: :fmt_identifier
          map_element "logo", to: :logo
        end
      end
    end
  end
end
