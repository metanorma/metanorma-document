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
          # Type-only (embedded) model: Organization carries the <logo>
          # tag through its own `map_element "logo"` mapping. A root-level
          # element declaration must NOT be added back: with an element
          # declared, lutaml-model drops the raw map_all_content capture
          # at the root (content comes out nil on every 0.8.x in the
          # supported range), while the embedded path — the only one this
          # class takes — round-trips it.
          map_attribute "type", to: :type
          map_all_content to: :content
        end
      end
    end
  end
end
