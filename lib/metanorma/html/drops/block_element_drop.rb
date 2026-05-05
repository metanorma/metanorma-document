# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class BlockElementDrop < Liquid::Drop
        attr_reader :id, :type, :label_html, :content_html, :css_class

        def initialize(attrs = {})
          attrs.each { |k, v| instance_variable_set(:"@#{k}", v) }
        end

        # Subclasses override to build from model + RendererContext
        def self.from_model(_model, renderer:)
          raise NotImplementedError, "#{name} must implement .from_model"
        end
      end
    end
  end
end
