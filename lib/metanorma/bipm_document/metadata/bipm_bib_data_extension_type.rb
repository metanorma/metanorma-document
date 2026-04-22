# frozen_string_literal: true

module Metanorma
  module BipmDocument
    module Metadata
      # Extension point for bibliographical definitions of BIPM documents.
      # Inherits all ISO extension fields; overrides structuredidentifier for BIPM format.
      class BipmBibDataExtensionType < Metanorma::IsoDocument::Metadata::IsoBibDataExtensionType
        attribute :structuredidentifier, BipmStructuredIdentifier
        attribute :si_aspect, :string

        xml do
          element "ext"
          map_element "structuredidentifier", to: :structuredidentifier
          map_element "si-aspect", to: :si_aspect
        end
      end
    end
  end
end
