# frozen_string_literal: true

module Metanorma
  module StandardDocument
    module Sections
      # A numbered clause constituting part of the main body of a _StandardDocument_.
      class ClauseSection < Metanorma::StandardDocument::Sections::StandardSection
        attribute :type, :string

        attribute :semx_id, :string
        attribute :original_id, :string
        attribute :autonum, :string
        attribute :displayorder, :integer
        attribute :inline_header, :string

        xml do
          element "clause"
          map_attribute "type", to: :type

          map_attribute "semx-id", to: :semx_id
          map_attribute "original-id", to: :original_id
          map_attribute "autonum", to: :autonum
          map_attribute "displayorder", to: :displayorder
          map_attribute "inline-header", to: :inline_header
        end
      end
    end
  end
end
