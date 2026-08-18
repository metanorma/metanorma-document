# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Cross-reference to a term defined within a termbase.
        class TermrefElement < Lutaml::Model::Serializable
          attribute :base, :string
          attribute :target, :string
          attribute :text, :string, collection: true

          xml do
            element "termref"
            mixed_content
            map_attribute "base", to: :base
            map_attribute "target", to: :target
            map_content to: :text
          end
        end
      end
    end
  end
end
