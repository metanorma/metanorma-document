# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Paragraph
        def self.call(element, context:)
          attrs = extract_attrs(element)
          content = Inline.extract_inline(element, context:)

          Node::Paragraph.new(attrs: attrs, content: content)
        end

        def self.extract_attrs(element)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:alignment] = SafeAttr.read(element, :alignment)
          attrs[:keep_with_next] = SafeAttr.read(element, :keep_with_next)
          attrs[:keep_with_previous] = SafeAttr.read(element, :keep_with_previous)
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)
          attrs.compact
        end
      end
    end
  end
end
