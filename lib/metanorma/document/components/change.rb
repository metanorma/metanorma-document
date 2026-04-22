# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Change
        autoload :AttributeChangeAction,
                 "#{__dir__}/change/attribute_change_action"
        autoload :AttributeModify, "#{__dir__}/change/attribute_modify"
        autoload :Change, "#{__dir__}/change/change"
        autoload :ChangeSet, "#{__dir__}/change/change_set"
        autoload :ContentAction, "#{__dir__}/change/content_action"
        autoload :ContentChange, "#{__dir__}/change/content_change"
        autoload :ContentChangeAction, "#{__dir__}/change/content_change_action"
        autoload :ContentModify, "#{__dir__}/change/content_modify"
        autoload :NodeChange, "#{__dir__}/change/node_change"
        autoload :NodeDelete, "#{__dir__}/change/node_delete"
        autoload :NodeInsert, "#{__dir__}/change/node_insert"
        autoload :NodeMove, "#{__dir__}/change/node_move"
        autoload :UniqueIdentifier, "#{__dir__}/change/unique_identifier"
      end
    end
  end
end
