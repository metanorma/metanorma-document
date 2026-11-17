# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module UpdateUnits
        # Localized summary of an amendment: one entry per language, so
        # a trilingual publication carries all its variants in one
        # record instead of one hand-maintained table per language.
        class Summary < Lutaml::Model::Serializable
          attribute :language, :string
          attribute :script, :string
          attribute :content, :string

          xml do
            element "summary"
            map_attribute "language", to: :language
            map_attribute "script", to: :script
            map_content to: :content
          end

          key_value do
            map "language", to: :language
            map "script", to: :script
            map "content", to: :content
          end
        end
      end
    end
  end
end
