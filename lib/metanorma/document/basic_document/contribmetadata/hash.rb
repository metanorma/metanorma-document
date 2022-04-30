# frozen_string_literal: true

require "basic_document/contribmetadata/integrity_value"

module Metanorma; module Document; module BasicDocument
  # Hash value for a digital signature.
  class Hash < IntegrityValue
    register_element do
      # Algorithm used to derive hash value, as defined in ISO 10118.
      attribute :algorithm, Iso10118Oid

      # Hash value.
      attribute :value, String
    end
  end
end; end; end
