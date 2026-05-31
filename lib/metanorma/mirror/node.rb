# frozen_string_literal: true

module Metanorma
  module Mirror
    class Node
      PM_TYPE = "node"

      attr_accessor :type, :attrs, :content, :marks

      def initialize(type: nil, attrs: {}, content: [], marks: [])
        @type = type || self.class::PM_TYPE
        @attrs = attrs || {}
        @content = content || []
        @marks = marks || []
      end

      def to_h
        result = { "type" => type }
        result["attrs"] = attrs.transform_keys(&:to_s) unless attrs.nil? || attrs.empty?
        result["marks"] = marks.map(&:to_h) if marks && !marks.empty?
        result["content"] = content.map(&:to_h) if content && !content.empty?
        result
      end

      alias to_hash to_h

      def to_json(**options)
        to_h.to_json(options)
      end

      def text_content
        return "" unless content

        content.filter_map do |item|
          next item if item.is_a?(String)
          next item.text_content if item.is_a?(Node)
        end.join
      end

      def self.from_h(hash)
        return nil unless hash

        type = hash["type"]
        attrs = hash["attrs"] || {}
        content = hash["content"] || []
        marks = hash["marks"] || []
        klass = NODES[type] || Node

        if klass == Text
          klass.custom_from_h(hash)
        else
          klass.new(
            attrs: attrs.transform_keys(&:to_sym),
            content: content.filter_map { |c| Node.from_h(c) },
            marks: marks.filter_map { |m| Mark.from_h(m) },
          )
        end
      end

      NODES = {} # rubocop:disable Style/MutableConstant

      # Document structure
      class Document < Node
        PM_TYPE = "doc"
      end

      class Preface < Node
        PM_TYPE = "preface"
      end

      class Sections < Node
        PM_TYPE = "sections"
      end

      class Bibliography < Node
        PM_TYPE = "bibliography"
      end

      # Section types
      class Clause < Node
        PM_TYPE = "clause"
      end

      class Annex < Node
        PM_TYPE = "annex"
      end

      class ContentSection < Node
        PM_TYPE = "content_section"
      end

      class Abstract < Node
        PM_TYPE = "abstract"
      end

      class Foreword < Node
        PM_TYPE = "foreword"
      end

      class Introduction < Node
        PM_TYPE = "introduction"
      end

      class Acknowledgements < Node
        PM_TYPE = "acknowledgements"
      end

      class Terms < Node
        PM_TYPE = "terms"
      end

      class Definitions < Node
        PM_TYPE = "definitions"
      end

      class References < Node
        PM_TYPE = "references"
      end

      # Block types
      class Paragraph < Node
        PM_TYPE = "paragraph"
      end

      class Note < Node
        PM_TYPE = "note"
      end

      class Admonition < Node
        PM_TYPE = "admonition"
      end

      class Example < Node
        PM_TYPE = "example"
      end

      class Figure < Node
        PM_TYPE = "figure"
      end

      class Image < Node
        PM_TYPE = "image"
      end

      class Sourcecode < Node
        PM_TYPE = "sourcecode"
      end

      class Formula < Node
        PM_TYPE = "formula"
      end

      class Table < Node
        PM_TYPE = "table"
      end

      class TableHead < Node
        PM_TYPE = "table_head"
      end

      class TableBody < Node
        PM_TYPE = "table_body"
      end

      class TableFoot < Node
        PM_TYPE = "table_foot"
      end

      class TableRow < Node
        PM_TYPE = "table_row"
      end

      class TableCell < Node
        PM_TYPE = "table_cell"
      end

      class Quote < Node
        PM_TYPE = "quote"
      end

      class Review < Node
        PM_TYPE = "review"
      end

      class FloatingTitle < Node
        PM_TYPE = "floating_title"
      end

      # List types
      class BulletList < Node
        PM_TYPE = "bullet_list"
      end

      class OrderedList < Node
        PM_TYPE = "ordered_list"
      end

      class ListItem < Node
        PM_TYPE = "list_item"
      end

      class DefinitionList < Node
        PM_TYPE = "dl"
      end

      class DefinitionTerm < Node
        PM_TYPE = "dt"
      end

      class DefinitionDescription < Node
        PM_TYPE = "dd"
      end

      # Footnotes
      class Footnotes < Node
        PM_TYPE = "footnotes"
      end

      class FootnoteMarker < Node
        PM_TYPE = "footnote_marker"
      end

      class FootnoteEntry < Node
        PM_TYPE = "footnote_entry"
      end

      # Text — special: has `text` attr instead of content
      class Text < Node
        PM_TYPE = "text"
        attr_accessor :text

        def initialize(text: "", **)
          super(**)
          @text = text
        end

        def to_h
          result = super
          result["text"] = text.to_s
          result
        end

        def text_content
          text.to_s
        end

        def self.custom_from_h(hash)
          new(
            text: hash["text"] || "",
            attrs: (hash["attrs"] || {}).transform_keys(&:to_sym),
            marks: (hash["marks"] || []).filter_map { |m| Mark.from_h(m) },
          )
        end
      end

      # Soft break
      class SoftBreak < Node
        PM_TYPE = "soft_break"
      end

      # Auto-register all nested subclasses by PM_TYPE
      constants.each do |name|
        klass = const_get(name)
        next unless klass.is_a?(Class) && klass < Node && klass::PM_TYPE != "node"

        NODES[klass::PM_TYPE] = klass
      end
    end
  end
end
