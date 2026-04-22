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
          attribute :locality_stack, Metanorma::Document::Relaton::LocalityStack,
                    collection: true

          xml do
            element "eref"
            map_attribute "id", to: :id
            map_attribute "type", to: :type
            map_attribute "bibitemid", to: :bibitemid
            map_attribute "citeas", to: :citeas
            map_attribute "normative", to: :normative
            map_attribute "alt", to: :alt
            map_element "localityStack", to: :locality_stack
          end
        end
      end
    end
  end
end
