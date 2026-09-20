# frozen_string_literal: true

module Metanorma
  module BsiDocument
    module Sections
      autoload :BsiAnnexSection, "#{__dir__}/sections/bsi_annex_section"
      autoload :BsiClauseSection, "#{__dir__}/sections/bsi_clause_section"
      autoload :BsiSections, "#{__dir__}/sections/bsi_sections"
    end
  end
end
