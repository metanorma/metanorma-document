# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Used to present a group of bibliographic items as a single group.
      class RelatonCollection < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :title, Metanorma::Document::Relaton::TypedTitleString,
                  collection: true
        attribute :contributor, Metanorma::Document::Relaton::ContributionInfo,
                  collection: true
        attribute :relation, Metanorma::Document::Relaton::DocumentRelation,
                  collection: true

        xml do
          map_attribute "type", to: :type
          map_element "title", to: :title
          map_element "contributor", to: :contributor
          map_element "relation", to: :relation
        end
      end
    end
  end
end
