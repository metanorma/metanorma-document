# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Blocks
        class RequirementBase < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :model, :string
          attribute :obligation, :string
          attribute :type, :string
          attribute :anchor, :string
          attribute :subject, :string
          attribute :classification, RequirementClassification, collection: true
          attribute :description, RequirementDescription, collection: true
          attribute :inherit, RequirementInherit, collection: true
          attribute :requirement, "Metanorma::Document::Components::Blocks::RequirementModel",
                    collection: true
          attribute :recommendation, "Metanorma::Document::Components::Blocks::RecommendationModel",
                    collection: true
          attribute :permission, "Metanorma::Document::Components::Blocks::PermissionModel",
                    collection: true
          attribute :example,
                    Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
                    collection: true
        end
      end
    end
  end
end
