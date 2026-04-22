# frozen_string_literal: true

module Metanorma
  module IeeeDocument
    module Metadata
      # Extension point for bibliographical definitions of IEEE documents.
      # Inherits all ISO extension fields; overrides structuredidentifier for IEEE format.
      class IeeeBibDataExtensionType < Metanorma::IsoDocument::Metadata::IsoBibDataExtensionType
        attribute :structuredidentifier, IeeeStructuredIdentifier

        xml do
          element "ext"
          map_element "structuredidentifier", to: :structuredidentifier
        end
      end
    end
  end
end
