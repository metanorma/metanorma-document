# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Blocks
        autoload :BasicBlock, "#{__dir__}/blocks/basic_block"
        autoload :BasicBlockNoNotes, "#{__dir__}/blocks/basic_block_no_notes"
        autoload :NoteBlock, "#{__dir__}/blocks/note_block"
        autoload :Passthrough, "#{__dir__}/blocks/passthrough"
        autoload :ClassificationValue, "#{__dir__}/blocks/requirement_model"
        autoload :RequirementClassification,
                 "#{__dir__}/blocks/requirement_model"
        autoload :RequirementDescription, "#{__dir__}/blocks/requirement_model"
        autoload :RequirementInherit, "#{__dir__}/blocks/requirement_model"
        autoload :RequirementBase, "#{__dir__}/blocks/requirement_model"
        autoload :RequirementModel, "#{__dir__}/blocks/requirement_model"
        autoload :RecommendationModel, "#{__dir__}/blocks/requirement_model"
        autoload :PermissionModel, "#{__dir__}/blocks/requirement_model"
      end
    end
  end
end
