# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Quote
        def self.call(element, context:)
          attrs = Handlers.extract_attrs(element)
          content = context.extract_blocks(element)

          Handlers.build_node("quote", attrs: attrs, content: content)
        end
      end
    end
  end
end
