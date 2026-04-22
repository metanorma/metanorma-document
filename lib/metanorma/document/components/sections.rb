# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Sections
        autoload :BasicSection, "#{__dir__}/sections/basic_section"
        autoload :ContentSection, "#{__dir__}/sections/content_section"
        autoload :HierarchicalSection,
                 "#{__dir__}/sections/hierarchical_section"
        autoload :ReferencesSection, "#{__dir__}/sections/references_section"
      end
    end
  end
end
