# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Logo image of an organization, with its raw (e.g. inline SVG) payload.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 Logo maps an
      # attribute-only Image, dropping the inline <svg> payloads (over a
      # thousand <path> elements) fixtures carry under <logo><image>;
      # map_all_content preserves them raw.
      class LogoElement < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :content, :string

        xml do
          element "logo"
          map_attribute "type", to: :type
          map_all_content to: :content
        end
      end
    end
  end
end
