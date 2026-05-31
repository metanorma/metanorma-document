# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      autoload :Paragraph, "#{__dir__}/handlers/paragraph"
      autoload :Section, "#{__dir__}/handlers/section"
      autoload :List, "#{__dir__}/handlers/list"
      autoload :Table, "#{__dir__}/handlers/table"
      autoload :Figure, "#{__dir__}/handlers/figure"
      autoload :Sourcecode, "#{__dir__}/handlers/sourcecode"
      autoload :Admonition, "#{__dir__}/handlers/admonition"
      autoload :Formula, "#{__dir__}/handlers/formula"
      autoload :Example, "#{__dir__}/handlers/example"
      autoload :Note, "#{__dir__}/handlers/note"
      autoload :Quote, "#{__dir__}/handlers/quote"
      autoload :Review, "#{__dir__}/handlers/review"
      autoload :Inline, "#{__dir__}/handlers/inline"
      autoload :Structural, "#{__dir__}/handlers/structural"
    end
  end
end
