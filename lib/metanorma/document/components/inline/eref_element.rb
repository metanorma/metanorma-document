# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        class ErefElement < Lutaml::Model::Serializable
          include Inline::Vocabulary

          attribute :id, :string
          attribute :type, :string
          attribute :bibitemid, :string
          attribute :citeas, :string
          attribute :normative, :boolean
          attribute :alt, :string
          attribute :display_format, :string
          attribute :relative, :string
          attribute :connective, :string
          attribute :custom_connective, :string
          attribute :locality_stack, Metanorma::Document::Relaton::LocalityStack,
                    collection: true
          attribute :locality, Metanorma::Document::Relaton::BibItemLocality,
                    collection: true

          xml do
            element "eref"
            mixed_content
            map_attribute "id", to: :id
            map_attribute "type", to: :type
            map_attribute "bibitemid", to: :bibitemid
            map_attribute "citeas", to: :citeas
            map_attribute "normative", to: :normative
            map_attribute "alt", to: :alt
            map_attribute "displayFormat", to: :display_format
            map_attribute "relative", to: :relative
            map_attribute "connective", to: :connective
            map_attribute "custom-connective", to: :custom_connective
            map_element "localityStack", to: :locality_stack
            map_element "locality", to: :locality
            map_content to: :text
            Vocabulary::VocabularyXmlMapping.apply_inline_mappings(self)
          end
        end
      end
    end
  end
end
