# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # The eref content contract (erefAttributes, CitationType,
        # ErefBody) shared by the semantic element and its rendered
        # twins fmt-eref/fmt-origin (identical grammar shapes).
        # Declared as a module and re-applied per class: lutaml-model
        # neither inherits xml mappings into a redeclared `xml do`
        # block nor inherits the attribute registry, so every
        # shape-sharing class applies both halves in full.
        module ErefContract
          module_function

          def declare_attributes(base)
            base.attribute :id, :string
            base.attribute :type, :string
            base.attribute :bibitemid, :string
            base.attribute :citeas, :string
            base.attribute :normative, :boolean
            base.attribute :alt, :string
            base.attribute :display_format, :string
            base.attribute :relative, :string
            base.attribute :connective, :string
            base.attribute :custom_connective, :string
            base.attribute :locality_stack, Metanorma::Document::Relaton::LocalityStack,
                           collection: true
            base.attribute :locality, Metanorma::Document::Relaton::BibItemLocality,
                           collection: true
          end

          def apply_mapping(mapping)
            mapping.mixed_content
            mapping.map_attribute "id", to: :id
            mapping.map_attribute "type", to: :type
            mapping.map_attribute "bibitemid", to: :bibitemid
            mapping.map_attribute "citeas", to: :citeas
            mapping.map_attribute "normative", to: :normative
            mapping.map_attribute "alt", to: :alt
            mapping.map_attribute "displayFormat", to: :display_format
            mapping.map_attribute "relative", to: :relative
            mapping.map_attribute "connective", to: :connective
            mapping.map_attribute "custom-connective", to: :custom_connective
            mapping.map_element "localityStack", to: :locality_stack
            mapping.map_element "locality", to: :locality
            mapping.map_content to: :text
            Vocabulary::VocabularyXmlMapping.apply_inline_mappings(mapping)
          end
        end

        class ErefElement < Lutaml::Model::Serializable
          include Inline::Vocabulary

          ErefContract.declare_attributes(self)

          xml do
            element "eref"
            ErefContract.apply_mapping(self)
          end
        end
      end
    end
  end
end
