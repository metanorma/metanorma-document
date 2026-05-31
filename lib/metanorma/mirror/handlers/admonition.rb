# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Admonition
        def self.call(element, context:)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:type] = SafeAttr.read(element, :type)
          attrs[:target] = SafeAttr.read(element, :target)
          attrs[:unnumbered] = SafeAttr.read(element, :unnumbered)
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)

          content = context.extract_blocks(element)

          Node::Admonition.new(attrs: attrs.compact, content: content)
        end
      end
    end
  end
end
