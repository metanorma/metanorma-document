# frozen_string_literal: true

require "basic_document/sections/basic_section"

module Metanorma; module Document; module StandardDocument
  # Section of a _StandardDocument_.
  class StandardSection < BasicDocument::BasicSection
    register_element do
      # Alternate titles for section.
      nodes :variant_title, Relaton::TypedTitleString

      # Force of this clause in the standards document.
      attribute :status, NormativeType

      # Specification of machine-readable change outlined in this section,
      # in a document amendment.
      node :amend, AmendBlock

      # Value of number to be used for numbering of section, overriding any autonumbering in rendering.
      attribute :number, String
    end
  end
end; end; end
