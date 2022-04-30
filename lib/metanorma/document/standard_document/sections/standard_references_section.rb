# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # The `StandardReferencesSection` class within _StandardDocument_
  # is used to represent a bibliography section.
  # It is used to collate references within the document, where
  # there could be one or more of such sections within a document.
  #
  # For example, some standardization documents differentiate
  # normative or informative references, some split references into
  # sections organized by concept relevance.
  #
  # Similar to the `ReferencesSection` of the _BasicDocument_ model,
  # they are leaf nodes which contain zero or more
  # bibliographical references (as modelled in Relaton), along with
  # any prefatory text.
  class StandardReferencesSection < Core::Node
  end
end; end; end
