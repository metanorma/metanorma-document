# frozen_string_literal: true

module Metanorma
  module Mirror
    class Transformer
      attr_reader :registry, :id_strategy

      def initialize(registry: Mirror.default_registry,
                     id_strategy: Mirror::DEFAULT_ID_STRATEGY)
        @registry = registry
        @id_strategy = id_strategy
      end

      def call(root)
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
          result.append_to(content)
        end

        sections = root.sections
        if sections
          result = @registry.handle(sections, context: self)
          result.append_to(content)
        end

        annex = root.annex
        annex&.each do |a|
          result = @registry.handle(a, context: self)
          result.append_to(content)
        end

        bibliography = root.bibliography
        if bibliography
          result = @registry.handle(bibliography, context: self)
          result.append_to(content)
        end

        Handlers.build_node("doc", attrs: attrs, content: content)
      end

      def from_metanorma(root)
        document = call(root)
        @id_strategy.finalize!(document)
      end

      def rewrite(mirror_node)
        Rewriter.new.call(mirror_node)
      end

      def extract_blocks(element)
        content = []

        element.each_mixed_content do |node|
          next if node.is_a?(String)

          result = @registry.handle(node, context: self)
          result.append_to(content)
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
            result.append_to(content)
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
            result.append_to(content)
          end
        end
        content
      end

      def text_node(text, marks: [])
        Handlers.build_text(text, marks: marks)
      end

      def extract_root_title(root)
        Metadata.title_from_bibdata(SafeAttr.read(root, :bibdata))
      end
    end
  end
end
