# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Review
        EXTRA = { date: nil, from: nil, to: nil, reviewer: nil,
                  display: nil }.freeze

        def self.call(element, context:)
          attrs = Handlers.extract_attrs(element, extra_attrs: EXTRA)
          content = context.extract_blocks(element)

          Handlers.build_node("review", attrs: attrs, content: content)
        end
      end
    end
  end
end
