# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # A cross-reference to another part of the document.
        #
        # Multi-target cross-references carry one or more `<location>`
        # children — secondary targets joined by connectives
        # (e.g. "see Figure 4, 5.1.6 and 5.1.7"). The primary target is
        # in the `target` attribute; secondary targets are in `location`.
        class XrefElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :target, :string
          attribute :style, :string
          attribute :format, :string
          attribute :pagenumber, :string
          attribute :nosee, :string
          attribute :nopage, :string
          attribute :alt, :string
          attribute :text, :string, collection: true
          attribute :location, LocationElement, collection: true

          xml do
            element "xref"
            map_attribute "id", to: :id
            map_attribute "target", to: :target
            map_attribute "style", to: :style
            map_attribute "format", to: :format
            map_attribute "pagenumber", to: :pagenumber
            map_attribute "nosee", to: :nosee
            map_attribute "nopage", to: :nopage
            map_attribute "alt", to: :alt
            map_content to: :text
            map_element "location", to: :location
          end
        end
      end
    end
  end
end
