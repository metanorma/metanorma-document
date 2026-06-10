# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Section
        def self.clause(element, context:)
          attrs = section_attrs(element, context:)
          content = context.extract_blocks(element)

          Handlers.build_node("clause", attrs: attrs, content: content)
        end

        def self.annex(element, context:)
          attrs = section_attrs(element, context:)
          attrs[:commentary] = SafeAttr.read(element, :commentary)
          attrs[:language] = SafeAttr.read(element, :language)
          attrs[:script] = SafeAttr.read(element, :script)

          content = context.extract_blocks(element)

          Handlers.build_node("annex", attrs: attrs.compact, content: content)
        end

        def self.content_section(element, context:)
          attrs = section_attrs(element, context:)
          content = context.extract_blocks(element)

          subsection = SafeAttr.read(element, :subsection)
          subsection&.each do |sub|
            result = context.registry.handle(sub, context: context)
            result.append_to(content)
          end

          Handlers.build_node("content_section", attrs: attrs, content: content)
        end

        def self.terms(element, context:)
          attrs = section_attrs(element, context:)
          content = context.extract_named_collections(element,
                                                      %i[p term dl example
                                                         admonition])
          children = context.extract_section_children(element)

          Handlers.build_node("terms", attrs: attrs, content: content + children)
        end

        def self.definitions(element, context:)
          attrs = section_attrs(element, context:)
          content = context.extract_blocks(element)

          Handlers.build_node("definitions", attrs: attrs, content: content)
        end

        def self.references(element, context:)
          attrs = section_attrs(element, context:)
          attrs[:normative] = SafeAttr.read(element, :normative)
          attrs[:hidden] = SafeAttr.read(element, :hidden)

          # Prefatory paragraphs (e.g. "The following documents are referred to...")
          content = context.extract_named_collections(element,
                                                      %i[p])

          # Bibliographic items
          refs = SafeAttr.read(element, :references)
          refs&.each do |ref|
            text = extract_biblio_text(ref)
            next if text.strip.empty?

            content << Handlers.build_node("paragraph",
              attrs: { id: SafeAttr.read(ref, :id) }.compact,
              content: [context.text_node(text)])
          end

          Handlers.build_node("references", attrs: attrs, content: content)
        end

        def self.extract_biblio_text(ref)
          parts = []

          tag = SafeAttr.read(ref, :biblio_tag)
          if tag
            tag_text = Inline.extract_formatted_text(tag).strip
            parts << tag_text unless tag_text.empty?
          end

          formatted = SafeAttr.read(ref, :formatted_ref)
          if formatted
            fmt_text = Inline.extract_formatted_text(formatted).strip
            parts << fmt_text unless fmt_text.empty?
          end

          return parts.join(" ") unless parts.empty?

          docid = SafeAttr.read(ref, :docidentifier)
          if docid
            text = Inline.extract_formatted_text(docid)
            return text unless text.strip.empty?
          end

          ""
        end

        def self.floating_title(element, context:)
          attrs = {}
          attrs[:id] = context.id_strategy.assign_id(element)
          attrs[:depth] = SafeAttr.read(element, :depth)
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)

          title = extract_title(element)
          attrs[:title] = title if title

          Handlers.build_node("floating_title", attrs: attrs.compact)
        end

        def self.section_attrs(element, context:)
          attrs = {}
          attrs[:id] = context.id_strategy.assign_id(element)
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
          else
            rich = Inline.extract_rich_html(title)
            rich.empty? ? Inline.extract_element_text(title) : rich
          end
        end
      end
    end
  end
end
