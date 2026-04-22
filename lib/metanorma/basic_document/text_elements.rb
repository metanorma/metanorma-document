# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module TextElements
      autoload :Asciiml, "#{__dir__}/text_elements/asciiml"
      autoload :EmphasisElement,
               "#{__dir__}/text_elements/emphasis_element"
      autoload :KeywordElement, "#{__dir__}/text_elements/keyword_element"
      autoload :Latex, "#{__dir__}/text_elements/latex"
      autoload :Mathml, "#{__dir__}/text_elements/mathml"
      autoload :MonospaceElement,
               "#{__dir__}/text_elements/monospace_element"
      autoload :RubyElement, "#{__dir__}/text_elements/ruby_element"
      autoload :SmallCapsElement,
               "#{__dir__}/text_elements/small_caps_element"
      autoload :StemElement, "#{__dir__}/text_elements/stem_element"
      autoload :StemType, "#{__dir__}/text_elements/stem_type"
      autoload :StemValue, "#{__dir__}/text_elements/stem_value"
      autoload :StrikeElement, "#{__dir__}/text_elements/strike_element"
      autoload :StrongElement, "#{__dir__}/text_elements/strong_element"
      autoload :SubscriptElement,
               "#{__dir__}/text_elements/subscript_element"
      autoload :SuperscriptElement,
               "#{__dir__}/text_elements/superscript_element"
      autoload :TextElement, "#{__dir__}/text_elements/text_element"
      autoload :TextElementType,
               "#{__dir__}/text_elements/text_element_type"
      autoload :UnderlineElement,
               "#{__dir__}/text_elements/underline_element"
    end
  end
end
