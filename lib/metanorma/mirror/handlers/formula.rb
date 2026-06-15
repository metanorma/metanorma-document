# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Formula
        EXTRA = { unnumbered: nil, inequality: nil }.freeze

        def self.call(element, context:)
          attrs = Handlers.extract_attrs(element, extra_attrs: EXTRA)

          stem = SafeAttr.read(element, :stem)
          if stem
            attrs[:stem_type] = SafeAttr.read(stem, :stem_type)

            asciimath = SafeAttr.read(stem, :asciimath)
            if asciimath&.value && !asciimath.value.strip.empty?
              attrs[:asciimath] =
                asciimath.value
            end

            math = SafeAttr.read(stem, :math)
            attrs[:mathml] = MathUtil.mathml_from_math(math) if math
          end

          # Legacy fallback: some older documents store text directly
          text = SafeAttr.read(element, :text)
          attrs[:math_text] = Array(text).join if text && !attrs[:asciimath]

          Handlers.build_node("formula", attrs: attrs.compact)
        end
      end
    end
  end
end
