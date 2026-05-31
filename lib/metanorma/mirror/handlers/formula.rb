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
            text = SafeAttr.read(stem, :text)
            attrs[:math_text] = Array(text).join if text
            attrs[:stem_type] = SafeAttr.read(stem, :stem_type)
          end

          Node::Formula.new(attrs: attrs.compact)
        end
      end
    end
  end
end
