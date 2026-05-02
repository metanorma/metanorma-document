module Metanorma
  module Document
    module Components
      module Inline
        class ErefElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :type, :string
          attribute :bibitemid, :string
          attribute :citeas, :string
          attribute :normative, :string
          attribute :alt, :string
          attribute :display_format, :string
          attribute :relative, :string
          attribute :locality_stack, Metanorma::Document::Relaton::LocalityStack,
                    collection: true
          attribute :text, :string

          xml do
            element "eref"
            map_attribute "id", to: :id
            map_attribute "type", to: :type
            map_attribute "bibitemid", to: :bibitemid
            map_attribute "citeas", to: :citeas
            map_attribute "normative", to: :normative
            map_attribute "alt", to: :alt
            map_attribute "displayFormat", to: :display_format
            map_attribute "relative", to: :relative
            map_element "localityStack", to: :locality_stack
            map_content to: :text
          end
        end
      end
    end
  end
end
