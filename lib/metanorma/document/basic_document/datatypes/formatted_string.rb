# frozen_string_literal: true

require "metanorma/document/basic_document/datatypes/localized_string"

module Metanorma; module Document; module BasicDocument
  # String which is formatted according to conventions specified
  # in a named MIME type (<<rfc2046>>).
  class FormattedString < LocalizedString
    register_element do
      # The corresponding MIME types, defaults to "text/plain".
      #
      # NOTE: `docbook`, `AsciiDoc`, `Metanorma` are not registered IANA Media Types.
      attribute :type, StringFormat
    end
  end
end; end; end
