# frozen_string_literal: true

module Metanorma
  module Html
    module Renderers
      class SectionRenderer
        def initialize(coordinator)
          @coordinator = coordinator
        end

        def render_basic_section(section, level: 1, **_opts)
          attrs = element_attrs(id: safe_attr(section, :id))
          title_html = render_section_title(section, level)
          content = section.blocks&.filter_map { |block| coordinator.render(block) }.join
          notes_html = section.notes&.filter_map { |note| coordinator.block_renderer.render_note(note) }.join
          render_liquid("_section.html.liquid", {
                          "attrs" => attrs,
                          "title" => title_html,
                          "content" => content,
                          "notes" => notes_html,
                        })
        end

        def render_hierarchical_section(section, level: 1, **_opts)
          attrs = element_attrs(id: safe_attr(section, :id))
          title_html = render_section_title(section, level)
          content = render_section_content(section, level)
          subsections_html = section.subsections&.filter_map { |sub| coordinator.render(sub, level: level + 1) }.join
          render_liquid("_section.html.liquid", {
                          "attrs" => attrs,
                          "title" => title_html,
                          "content" => "#{content}#{subsections_html}",
                        })
        end

        def render_content_section(section, level: 1, **_opts)
          render_hierarchical_section(section, level: level, **_opts)
        end

        def render_section_title(section, level)
          titles = section.title
          return nil unless titles
          return nil if titles.is_a?(Array) && titles.empty?

          h = "h#{[[level, 6].min, 1].max}"
          title_text = coordinator.extract_title_text(titles)
          render_liquid("_heading.html.liquid", "tag" => h, "class_attr" => "", "content" => escape_html(title_text))
        end

        def render_section_content(section, _level)
          parts = []
          section.blocks&.each { |block| parts << (coordinator.render(block) || "") }
          section.notes&.each { |note| parts << (coordinator.block_renderer.render_note(note) || "") }
          parts.join
        end

        def collect_ordered_children(section)
          children = []

          coordinator.inline_renderer.walk_ordered(section) do |type, obj|
            next if %i[text tab].include?(type)

            children << obj
          end

          supplementary_attrs = %i[terms definitions]
          supplementary_attrs.each do |attr|
            val = safe_attr(section, attr)
            next if val.nil?

            Array(val).each do |v|
              children << v unless children.include?(v)
            end
          end

          children.compact!
          sort_by_displayorder(children)
        end

        def render_ordered_content(section, level = 1)
          children = collect_ordered_children(section)
          parts = []
          children.each do |node|
            next if node.is_a?(String)
            next if coordinator.is_title_element?(node, section)

            parts << (coordinator.render(node, level: level + 1) || "")
          end
          parts.join
        end

        def sort_by_displayorder(children)
          children.sort_by do |node|
            order = if node.is_a?(Lutaml::Model::Serializable) &&
                node.class.attributes.key?(:displayorder)
                      node.displayorder
                    end
            order &&= order.to_i
            order || Float::INFINITY
          end
        end

        def render_preface(preface, **_opts)
          order = coordinator.theme.preface_order
          toc_filters = coordinator.theme.toc_filter_types

          if coordinator.theme.preface_wrap
            render_wrapped_preface(preface, order, toc_filters)
          else
            render_ordered_preface(preface, order, toc_filters)
          end
        end

        def render_ordered_preface(preface, order, toc_filters)
          parts = []
          order.each do |section_name|
            case section_name
            when "clause"
              clauses = preface_clauses_filtered(preface, toc_filters)
              clauses&.each { |cl| parts << (coordinator.render(cl, level: 1) || "") }
            else
              value = safe_attr(preface, section_name.to_sym)
              parts << (coordinator.render(value) || "") if value
            end
          end
          parts.join
        end

        def render_wrapped_preface(preface, order, toc_filters)
          clauses = preface_clauses_filtered(preface, toc_filters)
          other_sections = order.reject { |n| n == "clause" }
          has_others = other_sections.any? do |name|
            val = safe_attr(preface, name.to_sym)
            val && !Array(val).empty?
          end

          return nil if clauses.empty? && !has_others

          coordinator.register_toc_entry(id: "preface", level: 1, text: "Preface")
          content = clauses.filter_map { |cl| coordinator.render(cl, level: 2) }.join
          render_liquid("_wrapped_preface.html.liquid", content: content)
        end

        def preface_clauses_filtered(preface, toc_filters)
          clauses = safe_attr(preface, :clause) || safe_attr(preface, :content)
          clauses = Array(clauses)
          return clauses if toc_filters.empty?

          clauses.reject do |cl|
            cl_type = safe_attr(cl, :type)
            cl_type && toc_filters.include?(cl_type)
          end
        end

        private

        attr_reader :coordinator

        def safe_attr(obj, method_name)
          coordinator.safe_attr(obj, method_name)
        end

        def escape_html(text)
          coordinator.escape_html(text)
        end

        def element_attrs(**attrs)
          coordinator.element_attrs(**attrs)
        end

        def render_liquid(template_name, assigns)
          coordinator.render_liquid(template_name, assigns)
        end
      end
    end
  end
end
