# frozen_string_literal: true

module Metanorma
  module IsoDocument
    # Boilerplate section containing copyright statements and license text.
    # Uses map_all_content to preserve all child XML including inline
    # elements (span, link, br) inside paragraphs.
    class Boilerplate < Lutaml::Model::Serializable
      attribute :content, :string

      xml do
        element "boilerplate"
        map_all_content to: :content
      end
    end
  end
end
