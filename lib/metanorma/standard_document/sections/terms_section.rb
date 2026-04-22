# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Sections
      # Term sections give elaborated definitions of terms used in a standardization document.
      # The <terms> element contains <title>, <p>, <ul>, <term> children.
      class TermsSection < Metanorma::StandardDocument::Sections::ClauseSection
        attribute :terms, Metanorma::StandardDocument::Terms::Term,
                  collection: true

        attribute :semx_id, :string
        attribute :original_id, :string
        attribute :autonum, :string
        attribute :displayorder, :integer

        xml do
          element "terms"
          map_element "term", to: :terms

          map_attribute "semx-id", to: :semx_id
          map_attribute "original-id", to: :original_id
          map_attribute "autonum", to: :autonum
          map_attribute "displayorder", to: :displayorder
        end
      end
    end
  end
end
