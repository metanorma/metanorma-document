# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Figure
        def self.call(element, context:)
          attrs = figure_attrs(element)
          content = []

          img = SafeAttr.read(element, :image)
          if img
            img_attrs = {}
            src = SafeAttr.read(img, :source)
            img_attrs[:src] =
              src && !src.strip.empty? ? src : SafeAttr.read(img, :filename)
            img_attrs[:alt] = SafeAttr.read(img, :alt)
            img_attrs[:height] = SafeAttr.read(img, :height)
            img_attrs[:width] = SafeAttr.read(img, :width)
            content << Node::Image.new(attrs: img_attrs.compact)
          end

          subfigures = SafeAttr.read(element, :figure)
          subfigures&.each do |sub|
            result = call(sub, context: context)
            content << result if result
          end

          notes = SafeAttr.read(element, :note)
          notes&.each do |n|
            result = context.registry.handle(n, context: context)
            content << result[0] if result && result[0]
          end

          Node::Figure.new(attrs: attrs, content: content)
        end

        def self.figure_attrs(element)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:unnumbered] = SafeAttr.read(element, :unnumbered)
          attrs[:width] = SafeAttr.read(element, :width)
          attrs[:align] = SafeAttr.read(element, :align)
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)

          name = SafeAttr.read(element, :name)
          if name
            attrs[:title] = case name
                            when String then name
                            else extract_name_text(name)
                            end
          end
          attrs.compact
        end

        def self.extract_name_text(name)
          text = SafeAttr.read(name, :text)
          return text.to_s if text.is_a?(String) && !text.strip.empty?
          return Array(text).join.strip if text.is_a?(Array) && !text.empty?

          ""
        end
      end
    end
  end
end
