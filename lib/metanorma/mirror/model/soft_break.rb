# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      class SoftBreak
        def type
          "soft_break"
        end

        def to_h
          { "type" => "soft_break" }
        end

        def attrs
          {}
        end

        def content
          []
        end
      end
    end
  end
end
