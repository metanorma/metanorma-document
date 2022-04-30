# frozen_string_literal: true

require "standard_document/sections/standard_section"

module Metanorma; module Document; module StandardDocument
  # A numbered clause constituting part of the main body of a _StandardDocument_.
  class ClauseSection < StandardSection
    register_element "Clause-Section" do
      # Semantic class of the numbered clause.
      attribute :type, String
    end
  end
end; end; end
