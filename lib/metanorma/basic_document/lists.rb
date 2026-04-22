# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Lists
      autoload :Definition, "#{__dir__}/lists/definition"
      autoload :DefinitionList, "#{__dir__}/lists/definition_list"
      autoload :List, "#{__dir__}/lists/list"
      autoload :OrderedList, "#{__dir__}/lists/ordered_list"
      autoload :OrderedListType, "#{__dir__}/lists/ordered_list_type"
      autoload :UnorderedList, "#{__dir__}/lists/unordered_list"
    end
  end
end
