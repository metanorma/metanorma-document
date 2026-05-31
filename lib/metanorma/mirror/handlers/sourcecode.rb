# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Sourcecode
        def self.call(element, context:)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:language] = SafeAttr.read(element, :lang)
          attrs[:filename] = SafeAttr.read(element, :filename)
          attrs[:linenums] = SafeAttr.read(element, :linenums)
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)

          body = SafeAttr.read(element, :body)
          text = if body
                   Array(body.content).join
                 elsif SafeAttr.read(element, :content).is_a?(String)
                   SafeAttr.read(element, :content)
                 else
                   ""
                 end
          attrs[:text] = text

          Node::Sourcecode.new(attrs: attrs.compact)
        end
      end
    end
  end
end
