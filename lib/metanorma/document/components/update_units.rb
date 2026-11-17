# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      # Update units: divisions that are amended independently of the
      # publication that contains them (loose-leaf publications, where
      # a Section is replaced while the Part or edition stays). A
      # division declares its unit identity and carries its structured
      # amendment records; a Record of Updates is derived from these
      # records, never authored as free content.
      #
      # Amendment records state WHICH units changed; the add/del change
      # markup states HOW the text changed. The two are complementary.
      module UpdateUnits
        autoload :AmendmentRecord, "#{__dir__}/update_units/amendment_record"
        autoload :Summary, "#{__dir__}/update_units/summary"
        autoload :UpdateUnit, "#{__dir__}/update_units/update_unit"
        autoload :Validity, "#{__dir__}/update_units/validity"
      end
    end
  end
end
