# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # The status of a term as it is used in this document, relative to its definition in the original
  # document.
  class TermSourceStatus < Core::Node::Enum
    # The managed term in the present context is identical to the term as found in the bibliographic
    # source.
    IDENTICAL = new("identical")

    # The managed term in the present context has been modified from the term as found in the
    # bibliographic source.
    MODIFIED = new("modified")

    # The managed term in the present context has been restyled from the term as found in the
    # bibliographic source.
    RESTYLED = new("restyled")

    # The managed term in the present context has had context added to it, relative to the term as found
    # in the bibliographic source.
    CONTEXT_ADDED = new("context-added")

    # The managed term in the present context is a generalisation of the term as found in the
    # bibliographic source.
    GENERALISATION = new("generalisation")

    # The managed term in the present context is a specialisation of the term as found in the
    # bibliographic source.
    SPECIALISATION = new("specialisation")

    # The managed term in the present context is in an unspecified relation to the term as found in the
    # bibliographic source.
    UNSPECIFIED = new("unspecified")
  end
end; end; end
