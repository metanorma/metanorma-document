# frozen_string_literal: true

module Metanorma
  module Document
    # Base root class for all Metanorma document flavors.
    # All document types inherit from this.
    #
    # Carries the common document skeleton so neutral contexts —
    # notably collection doc-containers, which type embedded documents
    # against this class — retain the bibliographic identity across a
    # parse/serialize round-trip. Flavor roots extend this with their
    # own preface/sections/annex models.
    class Root < Lutaml::Model::Serializable
      attribute :autonum, :string
      attribute :fmt_xref_label, :string
      attribute :bibdata,
                Metanorma::BasicDocument::BibData::BibliographicItem

      xml do
        element "metanorma"
        map_element "bibdata", to: :bibdata
      end
    end
  end
end
