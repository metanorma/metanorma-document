# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Term
        def self.call(element, context:)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:anchor] = SafeAttr.read(element, :anchor)

          fmt_name = SafeAttr.read(element, :fmt_name)
          if fmt_name
            number = Inline.extract_formatted_text(fmt_name)
            attrs[:number] = number unless number.empty?
          end

          content = []

          # Term name from fmt_preferred paragraphs
          extract_fmt_paragraphs(element, :fmt_preferred, content, context)

          # Definition from fmt_definition → semx → p
          fmt_def = SafeAttr.read(element, :fmt_definition)
          if fmt_def
            extract_semx_paragraphs(fmt_def, content, context)
          end

          # Source from fmt_termsource
          fmt_ts_list = SafeAttr.read(element, :fmt_termsource)
          if fmt_ts_list && !fmt_ts_list.empty?
            source_text = Inline.extract_formatted_text(fmt_ts_list.first)
            unless source_text.empty?
              content << Handlers.build_node("paragraph",
                                             attrs: { class: "source" },
                                             content: [context.text_node(source_text)])
            end
          end

          # Term notes
          SafeAttr.read(element, :termnote)&.each do |tn|
            note_attrs = { id: SafeAttr.read(tn, :id) }
            fn = SafeAttr.read(tn, :fmt_name)
            if fn
              num = Inline.extract_formatted_text(fn)
              note_attrs[:number] = num unless num.empty?
            end
            note_content = context.extract_named_collections(tn, %i[p ul ol dl])
            content << Handlers.build_node("note", attrs: note_attrs.compact,
                                                   content: note_content)
          end

          # Term examples
          SafeAttr.read(element, :termexample)&.each do |te|
            ex_attrs = { id: SafeAttr.read(te, :id) }
            ex_content = context.extract_named_collections(te, %i[p ul ol dl])
            content << Handlers.build_node("example", attrs: ex_attrs.compact,
                                                      content: ex_content)
          end

          # Nested terms
          SafeAttr.read(element, :term)&.each do |t|
            result = context.registry.handle(t, context: context)
            result.append_to(content)
          end

          Handlers.build_node("term", attrs: attrs.compact, content: content)
        end

        def self.extract_fmt_paragraphs(element, attr_name, content, context)
          fmt_list = SafeAttr.read(element, attr_name)
          return unless fmt_list

          fmt_list.each do |fmt_el|
            ps = SafeAttr.read(fmt_el, :p)
            next unless ps

            ps.each do |p|
              result = context.registry.handle(p, context: context)
              result.append_to(content)
            end
          end
        end

        # fmt_definition wraps content in semx elements → extract p from semx
        def self.extract_semx_paragraphs(fmt_def, content, context)
          semx_list = SafeAttr.read(fmt_def, :semx)
          return unless semx_list

          Array(semx_list).each do |s|
            SafeAttr.read(s, :p)&.each do |p|
              result = context.registry.handle(p, context: context)
              result.append_to(content)
            end
          end
        end
      end
    end
  end
end
