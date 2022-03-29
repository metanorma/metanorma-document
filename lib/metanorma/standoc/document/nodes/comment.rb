# frozen_string_literal: true

module Metanorma; module Standoc; module Document; module Nodes
  # The XML comment node
  class Comment < Node
    def initialize(content)
      @content = content
    end

    attr_accessor :content

    def inspect
      "<!-- #{@content.inspect} -->"
    end

    def pretty_print(pp)
      pp.text "<!--"
      pp.group 2 do
        pp.breakable
        pp.pp @content
        pp.breakable
      end
      pp.text "-->"
    end

    def to_ng(ng_doc)
      Nokogiri::XML::Comment.new(ng_doc, content)
    end
  end
end; end; end; end
