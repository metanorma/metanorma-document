# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Series to which a bibliographic item belongs.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 maps partnumber/run
      # as elements (ours are attributes; lutaml-model 0.8.17 cannot override an
      # inherited element mapping with an attribute mapping without dropping the
      # value on render), types title as a sanitized collection, and restricts
      # type to main/alt while fixtures use stream/secondary/tertiary/intended.
      class SeriesType < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :formattedref, Metanorma::Document::Components::DataTypes::FormattedString
        attribute :title, Metanorma::Document::Relaton::TypedTitleString
        attribute :place, Metanorma::Document::Components::DataTypes::LocalizedString
        attribute :organization, Metanorma::Document::Relaton::Organization
        attribute :abbrev, Metanorma::Document::Components::DataTypes::LocalizedString
        attribute :abbreviation, Metanorma::Document::Components::DataTypes::LocalizedString
        attribute :from, Metanorma::Document::Relaton::DateTime
        attribute :to, Metanorma::Document::Relaton::DateTime
        attribute :number, :string
        attribute :partnumber, :string
        attribute :run, :string

        xml do
          map_attribute "type", to: :type
          map_element "formattedref", to: :formattedref
          map_element "title", to: :title
          map_element "place", to: :place
          map_element "organization", to: :organization
          map_element "abbrev", to: :abbrev
          map_element "abbreviation", to: :abbreviation
          map_element "from", to: :from
          map_element "to", to: :to
          map_element "number", to: :number
          map_attribute "partnumber", to: :partnumber
          map_attribute "run", to: :run
        end
      end
    end
  end
end
