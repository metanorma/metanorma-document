# frozen_string_literal: true

module Metanorma
  module CcDocument
    module Metadata
      # Extension point for bibliographical definitions of CC documents.
      # Inherits all ISO extension fields; CC adds nothing extra.
      class CcBibDataExtensionType < Metanorma::IsoDocument::Metadata::IsoBibDataExtensionType
      end
    end
  end
end
