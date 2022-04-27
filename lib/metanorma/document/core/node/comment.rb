# frozen_string_literal: true

module Metanorma; module Document; module Core; class Node
  # The XML comment node
  class Comment < Node
    def initialize(content)
      @content = content
      super()
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

    def ==(other)
      self.class == other.class &&
        self.content == other.content
    end
  end
end; end; end; end
