# frozen_string_literal: true

require "basic_document/datatypes/uri"

module Metanorma; module Document; module Relaton
  # URI associated with a type.
  class TypedUri < BasicDocument::Uri
    register_element do
      # The types of URI are open-ended, but include
      # the IANA link relations specified in <<rfc8288>>.
      nodes :type, String

      # URI.
      attribute :content, BasicDocument::Uri
    end
  end
end; end; end
