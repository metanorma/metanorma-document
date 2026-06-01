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

          # Prefatory paragraphs (e.g. "The following documents are referred to...")
          content = context.extract_named_collections(element,
                                                      %i[p]).map do |node|
            node
          end

          # Bibliographic items
          refs = SafeAttr.read(element, :references)
          refs&.each do |ref|
            text = extract_biblio_text(ref)
            next if text.strip.empty?

            content << Node::Paragraph.new(
              attrs: { id: SafeAttr.read(ref, :id) }.compact,
              content: [context.text_node(text)],
            )
          end

          Node::References.new(attrs: attrs, content: content)
        end

        def self.extract_biblio_text(ref)
          # Try formatted_ref first (the full formatted reference text)
          formatted = SafeAttr.read(ref, :formatted_ref)
          if formatted
            text = Inline.extract_formatted_text(formatted)
            return text unless text.strip.empty?
          end

          # Try biblio_tag (the short tag like "[1]")
          tag = SafeAttr.read(ref, :biblio_tag)
          if tag
            tag_text = Inline.extract_formatted_text(tag)
            unless tag_text.strip.empty?
              docid = SafeAttr.read(ref, :docidentifier)
              if docid
                id_text = Inline.extract_formatted_text(docid)
                return "#{tag_text} #{id_text}".strip unless id_text.strip.empty?
              end
              return tag_text
            end
          end

          # Fallback: try docidentifier alone
          docid = SafeAttr.read(ref, :docidentifier)
          if docid
            text = Inline.extract_formatted_text(docid)
            return text unless text.strip.empty?
          end

          ""
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
            joined = content.join
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
