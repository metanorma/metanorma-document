# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Formula
        def self.call(element, context:)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:unnumbered] = SafeAttr.read(element, :unnumbered)
          attrs[:inequality] = SafeAttr.read(element, :inequality)
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)

          stem = SafeAttr.read(element, :stem)
          if stem
            attrs[:stem_type] = SafeAttr.read(stem, :stem_type)

            asciimath = SafeAttr.read(stem, :asciimath)
            if asciimath&.value && !asciimath.value.strip.empty?
              attrs[:asciimath] =
                asciimath.value
            end

            math = SafeAttr.read(stem, :math)
            attrs[:mathml] = math.to_xml.sub(/\A<\?xml[^?]*\?>\s?/, "") if math
          end

          # Legacy fallback: some older documents store text directly
          text = SafeAttr.read(element, :text)
          attrs[:math_text] = Array(text).join if text && !attrs[:asciimath]

          Node::Formula.new(attrs: attrs.compact)
        end
      end
    end
  end
end
