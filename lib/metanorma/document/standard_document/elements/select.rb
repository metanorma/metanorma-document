# frozen_string_literal: true

require "standard_document/elements/form_input"

module Metanorma; module Document; module StandardDocument
  # Input allowing the selection of a value from a list of values. The value attribute is used instead
  # of a selected
  # attribute on a component option
  class Select < FormInput
  end
end; end; end
