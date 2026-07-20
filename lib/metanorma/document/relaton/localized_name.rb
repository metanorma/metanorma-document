# frozen_string_literal: true

require "relaton/bib"

module Metanorma
  module Document
    module Relaton
      # A name element with optional language and script attributes.
      # Inherits relaton-bib's TypedLocalizedString (gaining the type and
      # locale attribute mappings); content stays a collection under
      # mixed_content — this gem's organization and subdivision names allow
      # mixed text runs, which relaton-bib 2.2.0.pre.alpha.1's singular
      # content would flatten.
      class LocalizedName < ::Relaton::Bib::TypedLocalizedString
        attribute :content, :string, collection: true

        xml do
          element "name"
          mixed_content
          map_content to: :content
        end
      end
    end
  end
end
