# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Blocks
        autoload :BasicBlock, "#{__dir__}/blocks/basic_block"
        autoload :BasicBlockNoNotes, "#{__dir__}/blocks/basic_block_no_notes"
        autoload :ClassificationValue, "#{__dir__}/blocks/classification_value"
        autoload :FmtProvision, "#{__dir__}/blocks/fmt_provision"
        autoload :NoteBlock, "#{__dir__}/blocks/note_block"
        autoload :Passthrough, "#{__dir__}/blocks/passthrough"
        autoload :PermissionModel, "#{__dir__}/blocks/permission_model"
        autoload :RecommendationModel, "#{__dir__}/blocks/recommendation_model"
        autoload :RequirementBase, "#{__dir__}/blocks/requirement_base"
        autoload :RequirementClassification,
                 "#{__dir__}/blocks/requirement_classification"
        autoload :RequirementDescription,
                 "#{__dir__}/blocks/requirement_description"
        autoload :RequirementInherit, "#{__dir__}/blocks/requirement_inherit"
        autoload :RequirementImport, "#{__dir__}/blocks/requirement_import"
        autoload :RequirementMeasurementTarget,
                 "#{__dir__}/blocks/requirement_measurement_target"
        autoload :RequirementModel, "#{__dir__}/blocks/requirement_model"
        autoload :RequirementSpecification,
                 "#{__dir__}/blocks/requirement_specification"
        autoload :RequirementVerification,
                 "#{__dir__}/blocks/requirement_verification"
      end
    end
  end
end
