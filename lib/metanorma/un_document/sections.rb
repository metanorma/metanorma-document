# frozen_string_literal: true

module Metanorma
  module UnDocument
    module Sections
      autoload :UnAbstractSection, "#{__dir__}/sections/un_abstract_section"
      autoload :UnPreface, "#{__dir__}/sections/un_preface"
      autoload :UnSections, "#{__dir__}/sections/un_sections"
    end
  end
end
