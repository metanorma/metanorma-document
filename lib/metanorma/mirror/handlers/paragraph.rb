# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Paragraph
        EXTRA = { alignment: nil, keep_with_next: nil,
                  keep_with_previous: nil }.freeze

        def self.call(element, context:)
          attrs = Handlers.extract_attrs(element, extra_attrs: EXTRA)
          content = Inline.extract_inline(element, context:)

          Handlers.build_node("paragraph", attrs: attrs, content: content)
        end
      end
    end
  end
end
