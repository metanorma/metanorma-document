# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Type of simple Input element
  class InputType < Core::Node::Enum
    # Input element is a button
    BUTTON = new("button")

    # Input element is a checkbox
    CHECKBOX = new("checkbox")

    # Input element contains date
    DATE = new("date")

    # Input element selects file for upload
    FILE = new("file")

    # Input element is a password field
    PASSWORD = new("password")

    # Input element is a radio button
    RADIO = new("radio")

    # Input element is a submit button
    SUBMIT = new("submit")

    # Input element contains text
    TEXT = new("text")
  end
end; end; end
