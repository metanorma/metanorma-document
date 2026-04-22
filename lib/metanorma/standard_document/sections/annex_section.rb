# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Sections
      # Section of document constituting an annex or appendix.
      class AnnexSection < Metanorma::StandardDocument::Sections::StandardSection
        attribute :subsections,
                  Metanorma::StandardDocument::Sections::ClauseSection, collection: true

        attribute :semx_id, :string
        attribute :original_id, :string
        attribute :autonum, :string
        attribute :displayorder, :integer
        attribute :inline_header, :string
        attribute :type, :string

        xml do
          element "annex-section"
          map_element "subsections", to: :subsections

          map_attribute "semx-id", to: :semx_id
          map_attribute "original-id", to: :original_id
          map_attribute "autonum", to: :autonum
          map_attribute "displayorder", to: :displayorder
          map_attribute "inline-header", to: :inline_header
          map_attribute "type", to: :type
        end
      end
    end
  end
end
