# frozen_string_literal: true

require "basic_document/textelements/text_element"

module Metanorma; module Document; module BasicDocument
  # Text with Ruby annotations in East Asian languages. Corresponds to HTML `ruby`.
  class RubyElement < TextElement
    register_element "ruby" do
      # Ruby annotation. Corresponds to HTML `rp`.
      nodes :ruby_paren, LocalizedString, xml_tagname: "rp"

      # Ruby annotated text. Corresponds to HTML `rt`.
      nodes :ruby_text, LocalizedString, xml_tagname: "rt"
    end
  end
end; end; end
