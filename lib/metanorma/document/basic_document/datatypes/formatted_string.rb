# frozen_string_literal: true

require "basic_document/datatypes/localized_string"

module Metanorma; module Document; module BasicDocument
  # String which is formatted according to conventions specified
  # in a named MIME type (<<rfc2046>>).
  class FormattedString < LocalizedString
  end
end; end; end
