# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module Formats
        FORMAT_MAP = {} # rubocop:disable Style/MutableConstant

        autoload :BaseFormat, "#{__dir__}/formats/base_format"
        autoload :InlineFormat, "#{__dir__}/formats/inline_format"
      end
    end
  end
end
