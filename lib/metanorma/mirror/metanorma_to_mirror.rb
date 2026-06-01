# frozen_string_literal: true

module Metanorma
  module Mirror
    class MetanormaToMirror
      attr_reader :registry

      def initialize(registry: Mirror.default_registry)
        @registry = registry
        @footnote_counter = 0
        @footnotes = []
      end

      def call(root)
        @footnote_counter = 0
        @footnotes = []

        attrs = {}
        attrs[:flavor] = root.flavor if root.flavor
        attrs[:type] = root.type if root.type
        attrs[:schema_version] = root.schema_version if root.schema_version

        title = extract_root_title(root)
        attrs[:title] = title if title

        content = []

        preface = root.preface
        if preface
          result = @registry.handle(preface, context: self)
          content << result[0] if result && result[0]
        end

        sections = root.sections
        if sections
          result = @registry.handle(sections, context: self)
          content << result[0] if result && result[0]
        end

        annex = root.annex
        annex&.each do |a|
          result = @registry.handle(a, context: self)
          content << result[0] if result && result[0]
        end

        bibliography = root.bibliography
        if bibliography
          result = @registry.handle(bibliography, context: self)
          content << result[0] if result && result[0]
        end

        Node::Document.new(attrs: attrs, content: content)
      end

      def extract_blocks(element)
        content = []

        element.each_mixed_content do |node|
          next if node.is_a?(String)

          result = @registry.handle(node, context: self)
          next unless result && result[0]

          if result[1]
            content.concat(Array(result[0]))
          else
            content << result[0]
          end
        end
        content
      end

      def extract_section_children(element)
        content = []
        %i[clause terms definitions references floating_title].each do |attr|
          collection = SafeAttr.read(element, attr)
          next unless collection

          collection.each do |child|
            result = @registry.handle(child, context: self)
            next unless result && result[0]

            if result[1]
              content.concat(Array(result[0]))
            else
              content << result[0]
            end
          end
        end
        content
      end

      def extract_named_collections(element, collection_attrs)
        content = []
        collection_attrs.each do |attr|
          collection = SafeAttr.read(element, attr)
          next unless collection

          collection.each do |child|
            result = @registry.handle(child, context: self)
            next unless result && result[0]

            if result[1]
              content.concat(Array(result[0]))
            else
              content << result[0]
            end
          end
        end
        content
      end

      def text_node(text, marks: [])
        Node::Text.new(text: text, marks: marks)
      end

      def extract_root_title(root)
        bibdata = root.bibdata
        return nil unless bibdata

        title = bibdata.title
        return nil unless title

        case title
        when String then title
        when Array
          first = title.first
          return first.to_s unless first

          if first.is_a?(String)
            first
          elsif first.is_a?(Lutaml::Model::Serializable)
            Array(first.content).join
          else
            first.to_s
          end
        else title.to_s
        end
      end
    end
  end
end
