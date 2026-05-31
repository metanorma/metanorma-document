# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Quote
        def self.call(element, context:)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)

          content = context.extract_blocks(element)

          Node::Quote.new(attrs: attrs.compact, content: content)
        end
      end
    end
  end
end
