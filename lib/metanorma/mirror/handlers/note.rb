# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Note
        EXTRA = { type_attr: :type_attr, remove_in_rfc: nil }.freeze

        def self.call(element, context:)
          attrs = Handlers.extract_attrs(element, extra_attrs: EXTRA)

          content = []
          element_content = SafeAttr.read(element, :content)
          if element_content.is_a?(Array)
            element_content.each do |p|
              result = context.registry.handle(p, context: context)
              result.append_to(content)
            end
          end

          Handlers.build_node("note", attrs: attrs, content: content)
        end
      end
    end
  end
end
