# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Significant date in the lifecycle of the bibliographic item.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 Bib::Date has no
      # +format+ attribute and no text content, and casts on→at as StringDate
      # (nil-ing non-ISO values like "–") — fixture dates such as
      # <date type="published" format="ddMMMyyyy">I.2019</date> would
      # re-serialize as a bare <date type="published"/>.
      class BibliographicDate < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :format, :string
        attribute :text, :string
        attribute :from, DateTime
        attribute :to, DateTime
        attribute :on, DateTime

        xml do
          element "date"
          map_attribute "type", to: :type
          map_attribute "format", to: :format
          map_content to: :text
          map_element "from", to: :from
          map_element "to", to: :to
          map_element "on", to: :on
        end
      end
    end
  end
end
