# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Review
        def self.call(element, context:)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:date] = SafeAttr.read(element, :date)
          attrs[:from] = SafeAttr.read(element, :from)
          attrs[:to] = SafeAttr.read(element, :to)
          attrs[:reviewer] = SafeAttr.read(element, :reviewer)
          attrs[:display] = SafeAttr.read(element, :display)

          content = context.extract_blocks(element)

          Node::Review.new(attrs: attrs.compact, content: content)
        end
      end
    end
  end
end
