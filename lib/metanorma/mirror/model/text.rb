# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      class Text
        attr_reader :text, :marks

        def initialize(text:, marks: [])
          @text = text.to_s
          @marks = Array(marks)
        end

        def type
          "text"
        end

        def to_h
          h = { "type" => "text", "text" => @text }
          h["marks"] = @marks.map(&:to_h) unless @marks.empty?
          h
        end
      end
    end
  end
end
