# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # <refterm> outside a <concept> (e.g. inside a related-term semx
        # whose lookup failed): the native renderer serializes the element
        # itself as escaped text ("&lt;refterm&gt;…&lt;/refterm&gt;").
        class ReftermElement < Lutaml::Model::Serializable
          attribute :text, :string

          xml do
            element "refterm"
            map_content to: :text
          end
        end
      end
    end
  end
end
