# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Example
        EXTRA = { unnumbered: nil, subsequence: nil }.freeze

        def self.call(element, context:)
          attrs = Handlers.extract_attrs(element, extra_attrs: EXTRA)
          content = context.extract_named_collections(element,
                                                      %i[paragraphs formula
                                                         ul ol quote sourcecode
                                                         table figure dl])

          Handlers.build_node("example", attrs: attrs, content: content)
        end
      end
    end
  end
end
