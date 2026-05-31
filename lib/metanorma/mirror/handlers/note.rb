# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Note
        def self.call(element, context:)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:type] = SafeAttr.read(element, :type_attr)
          attrs[:remove_in_rfc] = SafeAttr.read(element, :remove_in_rfc)
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)

          content = []
          element_content = SafeAttr.read(element, :content)
          if element_content.is_a?(Array)
            element_content.each do |p|
              result = context.registry.handle(p, context: context)
              content << result[0] if result && result[0]
            end
          end

          Node::Note.new(attrs: attrs.compact, content: content)
        end
      end
    end
  end
end
