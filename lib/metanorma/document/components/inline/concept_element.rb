# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        class ConceptElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :bold, :boolean
          attribute :ital, :boolean
          attribute :ref, :boolean
          attribute :linkmention, :boolean
          attribute :linkref, :boolean
          attribute :refterm, :string, collection: true
          attribute :renderterm, :string, collection: true
          attribute :xref, XrefElement, collection: true
          attribute :eref, Metanorma::Document::Components::Inline::ErefElement
          attribute :erefstack, Metanorma::Document::Components::Inline::ErefStack
          attribute :termref, Metanorma::Document::Components::Inline::TermrefElement
          attribute :errormsg, Metanorma::Document::Components::Inline::ErrorMessage

          xml do
            element "concept"
            map_attribute "id", to: :id
            map_attribute "bold", to: :bold
            map_attribute "ital", to: :ital
            map_attribute "ref", to: :ref
            map_attribute "linkmention", to: :linkmention
            map_attribute "linkref", to: :linkref
            map_element "refterm", to: :refterm
            map_element "renderterm", to: :renderterm
            map_element "xref", to: :xref
            map_element "eref", to: :eref
            map_element "erefstack", to: :erefstack
            map_element "termref", to: :termref
            map_element "errormsg", to: :errormsg
          end
        end
      end
    end
  end
end
