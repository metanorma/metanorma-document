# frozen_string_literal: true

module Metanorma
  module Mirror
    class MirrorToMetanorma
      TYPE_BUILDERS = {
        "doc" => :build_document,
        "paragraph" => :build_paragraph,
        "note" => :build_note,
        "admonition" => :build_admonition,
        "example" => :build_example,
        "figure" => :build_figure,
        "image" => :build_image,
        "sourcecode" => :build_sourcecode,
        "formula" => :build_formula,
        "table" => :build_table,
        "table_head" => :build_table_section,
        "table_body" => :build_table_section,
        "table_foot" => :build_table_section,
        "table_row" => :build_table_row,
        "table_cell" => :build_table_cell,
        "quote" => :build_quote,
        "review" => :build_review,
        "clause" => :build_clause,
        "annex" => :build_annex,
        "content_section" => :build_content_section,
        "abstract" => :build_content_section,
        "foreword" => :build_content_section,
        "introduction" => :build_content_section,
        "acknowledgements" => :build_content_section,
        "terms" => :build_terms,
        "definitions" => :build_definitions,
        "references" => :build_references,
        "floating_title" => :build_floating_title,
        "bullet_list" => :build_bullet_list,
        "ordered_list" => :build_ordered_list,
        "list_item" => :build_list_item,
        "dl" => :build_dl,
        "dt" => :build_dt,
        "dd" => :build_dd,
        "preface" => :build_preface,
        "sections" => :build_sections,
        "bibliography" => :build_bibliography,
        "footnotes" => :build_footnotes,
        "soft_break" => :build_soft_break,
      }.freeze

      def call(mirror_node)
        hash = mirror_node.is_a?(Hash) ? mirror_node : mirror_node.to_h
        build_node(hash)
      end

      def build_node(node_hash)
        type = node_hash["type"]
        builder = TYPE_BUILDERS[type]
        return nil unless builder

        public_send(builder, node_hash)
      end

      def build_document(node)
        attrs = node["attrs"] || {}
        children = build_children(node)
        { type: "doc", attrs: attrs, content: children }
      end

      def build_paragraph(node)
        attrs = node["attrs"] || {}
        content = build_inline_children(node)
        { type: "paragraph", attrs: attrs, content: content }
      end

      def build_note(node)
        { type: "note", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_admonition(node)
        { type: "admonition", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_example(node)
        { type: "example", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_figure(node)
        { type: "figure", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_image(node)
        { type: "image", attrs: node["attrs"] || {} }
      end

      def build_sourcecode(node)
        { type: "sourcecode", attrs: node["attrs"] || {} }
      end

      def build_formula(node)
        { type: "formula", attrs: node["attrs"] || {} }
      end

      def build_table(node)
        { type: "table", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_table_section(node)
        { type: node["type"], content: build_children(node) }
      end

      def build_table_row(node)
        { type: "table_row", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_table_cell(node)
        { type: "table_cell", attrs: node["attrs"] || {},
          content: build_inline_children(node) }
      end

      def build_quote(node)
        { type: "quote", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_review(node)
        { type: "review", attrs: node["attrs"] || {} }
      end

      def build_clause(node)
        { type: "clause", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_annex(node)
        { type: "annex", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_content_section(node)
        { type: node["type"], attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_terms(node)
        { type: "terms", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_definitions(node)
        { type: "definitions", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_references(node)
        { type: "references", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_floating_title(node)
        { type: "floating_title", attrs: node["attrs"] || {} }
      end

      def build_bullet_list(node)
        { type: "bullet_list", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_ordered_list(node)
        { type: "ordered_list", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_list_item(node)
        { type: "list_item", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_dl(node)
        { type: "dl", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_dt(node)
        { type: "dt", attrs: node["attrs"] || {},
          content: build_inline_children(node) }
      end

      def build_dd(node)
        { type: "dd", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_preface(node)
        { type: "preface", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_sections(node)
        { type: "sections", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_bibliography(node)
        { type: "bibliography", attrs: node["attrs"] || {},
          content: build_children(node) }
      end

      def build_footnotes(_node)
        nil
      end

      def build_soft_break(_node)
        { type: "soft_break" }
      end

      def build_children(node)
        (node["content"] || []).filter_map { |child| build_node(child) }
      end

      def build_inline_children(node)
        (node["content"] || []).filter_map do |child|
          if child.is_a?(String)
            { type: "text", text: child }
          elsif child["type"] == "text"
            build_text(child)
          elsif child["type"] == "soft_break"
            { type: "soft_break" }
          else
            build_node(child)
          end
        end
      end

      def build_text(node)
        result = { type: "text", text: node["text"] || "" }
        marks = node["marks"]
        result[:marks] = marks if marks && !marks.empty?
        result
      end
    end
  end
end
