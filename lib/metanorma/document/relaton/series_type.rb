# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Series to which a bibliographic item belongs.
      class SeriesType < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :formattedref, Metanorma::Document::Components::DataTypes::FormattedString
        attribute :title, Metanorma::Document::Relaton::TypedTitleString
        attribute :place, Metanorma::Document::Components::DataTypes::LocalizedString
        attribute :organization, Metanorma::Document::Relaton::Organization
        attribute :abbrev, Metanorma::Document::Components::DataTypes::LocalizedString
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
