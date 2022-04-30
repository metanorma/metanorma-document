# frozen_string_literal: true

require "metanorma/document/basic_document/contribmetadata/integrity_value"

module Metanorma; module Document; module BasicDocument
  # Digital signature.
  class Signature < IntegrityValue
    register_element do
      # Algorithm used to derive digital signature, as defined in ISO 14888.
      attribute :algorithm, Iso14888Oid

      # Public key used to encode digital signature.
      attribute :public_key, String

      # Digital signature value.
      attribute :signature, String
    end
  end
end; end; end
