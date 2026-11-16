# frozen_string_literal: true

module Metanorma
  module Html
    module Component
      autoload :FrontMatter, "metanorma/html/component/front_matter"
      autoload :Base, "metanorma/html/component/base"
      autoload :IndexTermCollector,
               "metanorma/html/component/index_term_collector"
      autoload :IndexSection, "metanorma/html/component/index_section"
      autoload :FootnoteCollector, "metanorma/html/component/footnote_collector"
    end
  end
end
