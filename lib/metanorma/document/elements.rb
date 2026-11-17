# frozen_string_literal: true

module Metanorma
  module Document
    module Elements
      autoload :Add, "#{__dir__}/elements/add"
      autoload :Del, "#{__dir__}/elements/del"
      autoload :Option, "#{__dir__}/elements/option"
      autoload :Select, "#{__dir__}/elements/select"
      autoload :Textarea, "#{__dir__}/elements/textarea"
      autoload :Label, "#{__dir__}/elements/label"
      autoload :Input, "#{__dir__}/elements/input"
    end
  end
end
