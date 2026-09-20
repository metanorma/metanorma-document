# frozen_string_literal: true

module Metanorma
  module OgcDocument
    module Metadata
      # Extension point for bibliographical definitions of OGC documents.
      # Inherits all ISO extension fields; OGC adds nothing extra.
      class OgcBibDataExtensionType < Metanorma::IsoDocument::Metadata::IsoBibDataExtensionType
      end
    end
  end
end
