# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module ReferenceElements
        # A reference to an index term, cross-referenced within an index as an
        # alternative index entry, either as a "see" or a "see also" cross-reference.
        # The text in the inline element is the primary index term to be be cross-referenced.
        class IndexXrefElement < ReferenceElement
          attribute :secondary, :string
          attribute :tertiary, :string
          attribute :target, :string
          attribute :also, :boolean

          xml do
            element "index-xref-element"
            map_attribute "secondary", to: :secondary
            map_attribute "tertiary", to: :tertiary
            map_attribute "target", to: :target
            map_attribute "also", to: :also
          end
        end
      end
    end
  end
end
