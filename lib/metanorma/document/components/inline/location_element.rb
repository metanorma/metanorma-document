# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # A secondary target inside an `<xref>` for multi-target cross
        # references (e.g. "see Figure 4, 5.1.6 and 5.1.7"). Carries the
        # target id and the connective used to join it to the previous
        # target.
        class LocationElement < Lutaml::Model::Serializable
          attribute :target, :string
          attribute :connective, :string

          xml do
            element "location"
            map_attribute "target", to: :target
            map_attribute "connective", to: :connective
          end
        end
      end
    end
  end
end
