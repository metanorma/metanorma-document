# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module List
        def self.bullet(element, context:)
          attrs = list_attrs(element)
          items = extract_items(element, context:)

          Node::BulletList.new(attrs: attrs, content: items)
        end

        def self.ordered(element, context:)
          attrs = list_attrs(element)
          attrs[:type] = SafeAttr.read(element, :type)
          attrs[:start] = SafeAttr.read(element, :start)
          attrs[:group] = SafeAttr.read(element, :group)
          items = extract_items(element, context:)

          Node::OrderedList.new(attrs: attrs.compact, content: items)
        end

        def self.definition(element, context:)
          attrs = list_attrs(element)
          attrs[:key] = SafeAttr.read(element, :key)
          items = extract_definition_items(element, context:)

          Node::DefinitionList.new(attrs: attrs.compact, content: items)
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
              next unless result && result[0]

              if result[1]
                content.concat(Array(result[0]))
              else
                content << result[0]
              end
            end
          end

          Node::ListItem.new(attrs: attrs.compact, content: content)
        end

        def self.extract_items(element, context:)
          Array(element.listitem).filter_map do |li|
            result = context.registry.handle(li, context: context)
            result&.first
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
            items << Node::DefinitionTerm.new(attrs: dt_attrs.compact, content: dt_content)

            dd = dds[idx]
            next unless dd

            dd_attrs = {}
            dd_attrs[:id] = SafeAttr.read(dd, :id)
            dd_content = Inline.extract_inline(dd, context:)
            items << Node::DefinitionDescription.new(attrs: dd_attrs.compact, content: dd_content)
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
