# frozen_string_literal: true

module Metanorma
  module Html
    module Component
      class IndexSection < Base
        def render(collector, **opts)
          return if collector.nil? || collector.empty?

          output << tag(:div, %( id="index" class="index-section" data-component="index")) do
            html = tag(:h2) { "Index" }
            html << render_quicknav(collector.sorted_groups)
            html << render_letter_groups(collector.sorted_groups)
            html
          end

          renderer.register_toc_entry(id: "index", level: 1, text: "Index")
        end

        private

        def render_quicknav(groups)
          links = groups.filter_map do |g|
            %(<a href="#index-letter-#{escape_html(g.letter)}">#{escape_html(g.letter)}</a>)
          end.join
          %(<div class="index-quicknav">#{links}</div>)
        end

        def render_letter_groups(groups)
          groups.map { |g| render_letter_group(g) }.join
        end

        def render_letter_group(group)
          tag(:div, %( class="index-letter-group" id="index-letter-#{escape_html(group.letter)}")) do
            html = tag(:h3, %( class="index-letter")) { group.letter }
            html << group.entries.map { |e| render_entry(e, "primary") }.join
            html
          end
        end

        def render_entry(entry, level)
          tag(:div, %( class="index-entry index-entry--#{level}")) do
            html = +""
            html << tag(:span, %( class="index-term")) { escape_html(entry.term) }
            html << render_locators(entry.locators)
            html << render_see(entry.see) if entry.see
            html << render_see_also(entry.see_also_entries) unless entry.see_also_entries.empty?
            html << entry.children.map { |c| render_entry(c, next_level(level)) }.join unless entry.children.empty?
            html
          end
        end

        def render_locators(locators)
          links = locators.map do |loc|
            tag(:a, %( href="##{escape_html(loc.id)}")) { escape_html(loc.text) }
          end
          tag(:span, %( class="index-locator")) { links.join(", ") }
        end

        def render_see(term)
          tag(:div, %( class="index-see")) { "<em>see</em> #{escape_html(term)}" }
        end

        def render_see_also(terms)
          tag(:div, %( class="index-see-also")) { "<em>see also</em> #{terms.map { |t| escape_html(t) }.join(', ')}" }
        end

        def next_level(level)
          { "primary" => "secondary", "secondary" => "tertiary" }[level] || "tertiary"
        end
      end
    end
  end
end
