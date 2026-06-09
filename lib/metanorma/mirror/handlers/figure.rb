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
            content << Handlers.build_node("image", attrs: img_attrs.compact)
          end

          subfigures = SafeAttr.read(element, :figure)
          subfigures&.each do |sub|
            result = context.registry.handle(sub, context: context)
            result.append_to(content)
          end

          notes = SafeAttr.read(element, :note)
          notes&.each do |n|
            result = context.registry.handle(n, context: context)
            result.append_to(content)
          end

          Handlers.build_node("figure", attrs: attrs, content: content)
        end

        def self.figure_attrs(element)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:unnumbered] = SafeAttr.read(element, :unnumbered)
          attrs[:width] = SafeAttr.read(element, :width)
          attrs[:align] = SafeAttr.read(element, :align)
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)

          name = SafeAttr.read(element, :name)
          attrs[:title] = Handlers.extract_name_text(name) if name
          attrs.compact
        end
      end
    end
  end
end
