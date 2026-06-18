# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module List
        def self.bullet(element, context:)
          attrs = list_attrs(element)
          items = extract_items(element, context:)

          Handlers.build_node("bullet_list", attrs: attrs, content: items)
        end

        def self.ordered(element, context:)
          attrs = list_attrs(element)
          attrs[:type] = SafeAttr.read(element, :type)
          attrs[:start] = SafeAttr.read(element, :start)
          attrs[:group] = SafeAttr.read(element, :group)
          items = extract_items(element, context:)

          Handlers.build_node("ordered_list", attrs: attrs.compact,
                                              content: items)
        end

        def self.definition(element, context:)
          attrs = list_attrs(element)
          attrs[:key] = SafeAttr.read(element, :key)
          items = extract_definition_items(element, context:)

          Handlers.build_node("dl", attrs: attrs.compact, content: items)
        end

        def self.list_item(element, context:)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:checkbox] = SafeAttr.read(element, :checkbox)
          attrs[:checkedcheckbox] = SafeAttr.read(element, :checkedcheckbox)

          content = []
          text = SafeAttr.read(element, :text)
          if text.is_a?(Array)
            text.each do |t|
              next if t.is_a?(String) && t.strip.empty?

              content << context.text_node(t.to_s)
            end
          end

          %i[paragraphs unordered_lists ordered_lists sourcecode figure example
             note quote table].each do |attr|
            collection = SafeAttr.read(element, attr)
            next unless collection

            collection.each do |child|
              result = context.registry.handle(child, context: context)
              result.append_to(content)
            end
          end

          Handlers.build_node("list_item", attrs: attrs.compact,
                                           content: content)
        end

        def self.extract_items(element, context:)
          Array(element.listitem).filter_map do |li|
            result = context.registry.handle(li, context: context)
            result.nodes
          end
        end

        def self.extract_definition_items(element, context:)
          items = []
          dts = Array(element.dt)
          dds = Array(element.dd)

          dts.each_with_index do |dt, idx|
            dt_attrs = {}
            dt_attrs[:id] = SafeAttr.read(dt, :id)
            dt_content = Inline.extract_inline(dt, context:)
            items << Handlers.build_node("dt", attrs: dt_attrs.compact,
                                               content: dt_content)

            dd = dds[idx]
            next unless dd

            dd_attrs = {}
            dd_attrs[:id] = SafeAttr.read(dd, :id)
            dd_content = context.extract_named_collections(dd,
                                                           %i[p ul ol
                                                              sourcecode figure example note table formula quote dl])
            items << Handlers.build_node("dd", attrs: dd_attrs.compact,
                                               content: dd_content)
          end
          items
        end

        def self.list_attrs(element)
          attrs = {}
          attrs[:id] = SafeAttr.read(element, :id)
          attrs[:nobullet] = SafeAttr.read(element, :nobullet)
          attrs[:bare] = SafeAttr.read(element, :bare)
          attrs[:spacing] = SafeAttr.read(element, :spacing)
          attrs[:indent] = SafeAttr.read(element, :indent)
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)
          attrs.compact
        end
      end
    end
  end
end
