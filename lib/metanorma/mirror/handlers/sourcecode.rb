# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Sourcecode
        EXTRA = { language: :lang, filename: nil, linenums: nil }.freeze

        def self.call(element, context:)
          attrs = Handlers.extract_attrs(element, extra_attrs: EXTRA)

          body = SafeAttr.read(element, :body)
          text = if body
                   Array(body.content).join
                 elsif SafeAttr.read(element, :content).is_a?(String)
                   SafeAttr.read(element, :content)
                 else
                   ""
                 end
          attrs[:text] = text

          Handlers.build_node("sourcecode", attrs: attrs.compact)
        end
      end
    end
  end
end
