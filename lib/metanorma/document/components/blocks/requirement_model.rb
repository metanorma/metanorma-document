# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Blocks
        class ClassificationValue < Lutaml::Model::Serializable
          attribute :text, :string, collection: true
          attribute :link, Metanorma::Document::Components::Inline::LinkElement,
                    collection: true

          xml do
            mixed_content
            map_content to: :text
            map_element "link", to: :link
          end
        end

        class RequirementClassification < Lutaml::Model::Serializable
          attribute :tag, :string
          attribute :value, ClassificationValue

          xml do
            element "classification"
            map_element "tag", to: :tag
            map_element "value", to: :value
          end
        end

        class RequirementDescription < Lutaml::Model::Serializable
          attribute :p, Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                    collection: true
          attribute :ul, Metanorma::Document::Components::Lists::UnorderedList,
                    collection: true
          attribute :ol, Metanorma::Document::Components::Lists::OrderedList,
                    collection: true
          attribute :sourcecode,
                    Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock,
                    collection: true
          attribute :table, Metanorma::Document::Components::Tables::TableBlock,
                    collection: true
          attribute :example,
                    Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
                    collection: true
          attribute :note, Metanorma::Document::Components::Blocks::NoteBlock,
                    collection: true
          attribute :figure,
                    Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
                    collection: true

          xml do
            element "description"
            map_element "p", to: :p
            map_element "ul", to: :ul
            map_element "ol", to: :ol
            map_element "sourcecode", to: :sourcecode
            map_element "table", to: :table
            map_element "example", to: :example
            map_element "note", to: :note
            map_element "figure", to: :figure
          end
        end

        class RequirementInherit < Lutaml::Model::Serializable
          attribute :text, :string, collection: true
          attribute :eref, Metanorma::Document::Components::Inline::ErefElement,
                    collection: true
          attribute :xref, Metanorma::Document::Components::Inline::XrefElement,
                    collection: true

          xml do
            mixed_content
            map_content to: :text
            map_element "eref", to: :eref
            map_element "xref", to: :xref
          end
        end

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

        class RequirementModel < RequirementBase
          xml do
            element "requirement"
            map_attribute "id", to: :id
            map_attribute "model", to: :model
            map_attribute "obligation", to: :obligation
            map_attribute "type", to: :type
            map_attribute "anchor", to: :anchor
            map_element "subject", to: :subject
            map_element "classification", to: :classification
            map_element "description", to: :description
            map_element "inherit", to: :inherit
            map_element "requirement", to: :requirement
            map_element "recommendation", to: :recommendation
            map_element "permission", to: :permission
            map_element "example", to: :example
          end
        end

        class RecommendationModel < RequirementBase
          xml do
            element "recommendation"
            map_attribute "id", to: :id
            map_attribute "model", to: :model
            map_attribute "obligation", to: :obligation
            map_attribute "type", to: :type
            map_attribute "anchor", to: :anchor
            map_element "subject", to: :subject
            map_element "classification", to: :classification
            map_element "description", to: :description
            map_element "inherit", to: :inherit
            map_element "requirement", to: :requirement
            map_element "recommendation", to: :recommendation
            map_element "permission", to: :permission
            map_element "example", to: :example
          end
        end

        class PermissionModel < RequirementBase
          xml do
            element "permission"
            map_attribute "id", to: :id
            map_attribute "model", to: :model
            map_attribute "obligation", to: :obligation
            map_attribute "type", to: :type
            map_attribute "anchor", to: :anchor
            map_element "subject", to: :subject
            map_element "classification", to: :classification
            map_element "description", to: :description
            map_element "inherit", to: :inherit
            map_element "requirement", to: :requirement
            map_element "recommendation", to: :recommendation
            map_element "permission", to: :permission
            map_element "example", to: :example
          end
        end
      end
    end
  end
end
