# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Example
        def self.call(element, context:)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:unnumbered] = SafeAttr.read(element, :unnumbered)
          attrs[:subsequence] = SafeAttr.read(element, :subsequence)
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)

          content = context.extract_blocks(element)

          Node::Example.new(attrs: attrs.compact, content: content)
        end
      end
    end
  end
end
