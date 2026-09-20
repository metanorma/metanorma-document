# frozen_string_literal: true

module Metanorma
  module RiboseDocument
    module Metadata
      # Extension point for bibliographical definitions of Ribose documents.
      # Inherits all ISO extension fields; adds security and recipient.
      class RiboseBibDataExtensionType < Metanorma::IsoDocument::Metadata::IsoBibDataExtensionType
        attribute :security, :string
        attribute :recipient, :string

        xml do
          element "ext"
          map_element "security", to: :security
          map_element "recipient", to: :recipient
        end
      end
    end
  end
end
