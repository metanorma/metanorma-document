# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # The classes of block subject to autonumbering within an `AmendBlock` `newContent` element.
  class ElementName < Core::Node::Enum
    REQUIREMENT = new("requirement")

    RECOMMENDATION = new("recommendation")

    PERMISSION = new("permission")

    TABLE = new("table")

    FIGURE = new("figure")

    ADMONITION = new("admonition")

    FORMULA = new("formula")

    SOURCECODE = new("sourcecode")

    EXAMPLE = new("example")

    NOTE = new("note")
  end
end; end; end
