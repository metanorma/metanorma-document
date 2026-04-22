# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module EmptyElements
      autoload :BasicElement, "#{__dir__}/empty_elements/basic_element"
      autoload :HorizontalRuleElement,
               "#{__dir__}/empty_elements/horizontal_rule_element"
      autoload :IndexElement, "#{__dir__}/empty_elements/index_element"
      autoload :LineBreakElement,
               "#{__dir__}/empty_elements/line_break_element"
      autoload :PageBreakElement,
               "#{__dir__}/empty_elements/page_break_element"
    end
  end
end
