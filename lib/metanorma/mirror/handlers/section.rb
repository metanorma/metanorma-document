# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Section
        def self.clause(element, context:)
          attrs = section_attrs(element)
          content = context.extract_blocks(element)
          children = context.extract_section_children(element)

          Node::Clause.new(attrs: attrs, content: content + children)
        end

        def self.annex(element, context:)
          attrs = section_attrs(element)
          attrs[:commentary] = SafeAttr.read(element, :commentary)
          attrs[:language] = SafeAttr.read(element, :language)
          attrs[:script] = SafeAttr.read(element, :script)

          content = context.extract_blocks(element)
          children = context.extract_section_children(element)

          Node::Annex.new(attrs: attrs.compact, content: content + children)
        end

        def self.content_section(element, context:)
          attrs = section_attrs(element)
          content = context.extract_blocks(element)

          subsection = SafeAttr.read(element, :subsection)
          subsection&.each do |sub|
            result = context.registry.handle(sub, context: context)
            content << result[0] if result && result[0]
          end

          Node::ContentSection.new(attrs: attrs, content: content)
        end

        def self.terms(element, context:)
          attrs = section_attrs(element)
          content = context.extract_blocks(element)

          Node::Terms.new(attrs: attrs, content: content)
        end

        def self.definitions(element, context:)
          attrs = section_attrs(element)
          content = context.extract_blocks(element)

          Node::Definitions.new(attrs: attrs, content: content)
        end

        def self.references(element, context:)
          attrs = section_attrs(element)
          attrs[:normative] = SafeAttr.read(element, :normative)
          attrs[:hidden] = SafeAttr.read(element, :hidden)

          content = []
          paragraphs = SafeAttr.read(element, :paragraphs)
          paragraphs&.each { |p| handle_child(p, content, context:) }

          Node::References.new(attrs: attrs, content: content)
        end

        def self.floating_title(element, context:)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:depth] = SafeAttr.read(element, :depth)
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)

          title = extract_title(element)
          attrs[:title] = title if title

          Node::FloatingTitle.new(attrs: attrs.compact)
        end

        def self.section_attrs(element)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:number] = SafeAttr.read(element, :number)
          attrs[:obligation] = SafeAttr.read(element, :obligation)
          attrs[:unnumbered] = SafeAttr.read(element, :unnumbered)
          attrs[:toc] = SafeAttr.read(element, :toc)
          attrs[:type] = SafeAttr.read(element, :type)
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)
          attrs[:autonum] = SafeAttr.read(element, :autonum)
          attrs[:displayorder] = SafeAttr.read(element, :displayorder)

          title = extract_title(element)
          attrs[:title] = title if title
          attrs.compact
        end

        def self.extract_title(element)
          title = SafeAttr.read(element, :title)
          return nil unless title

          case title
          when String then title
          else extract_text_from_element(title)
          end
        end

        def self.extract_text_from_element(element)
          text = SafeAttr.read(element, :text)
          if text.is_a?(Array)
            joined = text.join
            return joined unless joined.strip.empty?
          end

          content = SafeAttr.read(element, :content)
          if content.is_a?(Array)
            joined = content.map(&:to_s).join
            return joined unless joined.strip.empty?
          end

          element.to_s
        end

        def self.handle_child(child, content, context:)
          result = context.registry.handle(child, context: context)
          return unless result && result[0]

          if result[1]
            content.concat(Array(result[0]))
          else
            content << result[0]
          end
        end
      end
    end
  end
end
