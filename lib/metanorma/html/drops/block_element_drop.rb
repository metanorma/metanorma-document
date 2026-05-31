# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class BlockElementDrop < Liquid::Drop
        attr_reader :id, :type, :label_html, :content_html, :css_class

        def initialize(id: nil, type: nil, label_html: nil, content_html: nil, css_class: nil)
          @id = id
          @type = type
          @label_html = label_html
          @content_html = content_html
          @css_class = css_class
        end

        # Subclasses override to build from model + RendererContext
        def self.from_model(_model, renderer:)
          raise NotImplementedError, "#{name} must implement .from_model"
        end
      end
    end
  end
end
