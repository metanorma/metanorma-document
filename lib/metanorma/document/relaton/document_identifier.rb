# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # An identifier of a bibliographic item in an international standard scheme.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 Docidentifier
      # inherits LocalizedMarkedUpString, whose Sanitizer strips
      # span/semx/link/fmt-* from the content at assignment time, and reads
      # the identifier string as +content+ (ours is +id+).
      class DocumentIdentifier < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :type, :string
        attribute :language, :string
        attribute :primary, :boolean
        attribute :scope, :string

        xml do
          element "docidentifier"
          map_attribute "type", to: :type
          map_attribute "language", to: :language
          map_attribute "primary", to: :primary
          map_attribute "scope", to: :scope
          map_content to: :id
        end
      end
    end
  end
end
