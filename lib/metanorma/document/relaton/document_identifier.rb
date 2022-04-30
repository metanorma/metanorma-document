# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # An identifier of a bibliographic item in an international standard scheme.
  class DocumentIdentifier < Core::Node
    include Core::Node::Custom

    register_element do
      # The identifier string.
      attribute :id, String

      # The scheme or namespace of the identifier.
      attribute :type, String

      # This is a primary identifier for the item, to be used in citation.
      attribute :primary, TrueClass

      # The scope of the identifier, in case the identifier is not for the document
      # but for a superset or subset of entities; or in case the identifier
      # is for a particular instance of the document, e.g. for a particular format or edition of the
      # document.
      attribute :scope, String
    end
  end
end; end; end
