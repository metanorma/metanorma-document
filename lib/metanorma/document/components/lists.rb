# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Lists
        autoload :DdElement, "#{__dir__}/lists/dd_element"
        autoload :Definition, "#{__dir__}/lists/definition"
        autoload :DefinitionList, "#{__dir__}/lists/definition_list"
        autoload :DtElement, "#{__dir__}/lists/dt_element"
        autoload :List, "#{__dir__}/lists/list"
        autoload :ListItem, "#{__dir__}/lists/list_item"
        autoload :OrderedList, "#{__dir__}/lists/ordered_list"
        autoload :OrderedListType, "#{__dir__}/lists/ordered_list_type"
        autoload :UnorderedList, "#{__dir__}/lists/unordered_list"
      end
    end
  end
end
