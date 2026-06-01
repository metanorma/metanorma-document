# frozen_string_literal: true

module Metanorma
  module Html
    module Component
      class IndexSection < Base
        def render(collector, **_opts)
          return if collector.nil? || collector.empty?

          quicknav = render_quicknav(collector.sorted_groups)
          letter_groups = render_letter_groups(collector.sorted_groups)
          content = quicknav + letter_groups

          attrs = %( id="index" class="index-section" data-component="index")
          index_html = render_liquid("_element.html.liquid", "tag" => "div",
                                                             "extra_attrs" => attrs, "content" => content)

          renderer.register_toc_entry(id: "index", level: 1, text: "Index")
          index_html
        end

        private

        def render_quicknav(groups)
          links = groups.filter_map do |g|
            letter = escape_html(g.letter)
            render_liquid("_link.html.liquid",
                          "attrs" => %( href="#index-letter-#{letter}"), "display_text" => letter)
          end.join
          render_liquid("_element.html.liquid", "tag" => "div",
                                                "extra_attrs" => " class=\"index-quicknav\"", "content" => links)
        end

        def render_letter_groups(groups)
          groups.map { |g| render_letter_group(g) }.join
        end

        def render_letter_group(group)
          letter = escape_html(group.letter)
          heading = render_liquid("_heading.html.liquid", "tag" => "h3",
                                                          "class_attr" => " class=\"index-letter\"", "content" => letter)
          entries = group.entries.map { |e| render_entry(e, "primary") }.join
          render_liquid("_element.html.liquid", "tag" => "div",
                                                "extra_attrs" => %( class="index-letter-group" id="index-letter-#{letter}"), "content" => "#{heading}#{entries}")
        end

        def render_entry(entry, level)
          term_html = render_liquid("_element.html.liquid", "tag" => "span",
                                                            "extra_attrs" => " class=\"index-term\"", "content" => escape_html(entry.term))
          locators_html = render_locators(entry.locators)
          inner = term_html + locators_html
          inner << render_see(entry.see) if entry.see
          inner << render_see_also(entry.see_also_entries) unless entry.see_also_entries.empty?
          unless entry.children.empty?
            inner << entry.children.map { |c|
              render_entry(c, next_level(level))
            }.join
          end
          render_liquid("_element.html.liquid", "tag" => "div",
                                                "extra_attrs" => %( class="index-entry index-entry--#{level}"), "content" => inner)
        end

        def render_locators(locators)
          links = locators.map do |loc|
            render_liquid("_link.html.liquid",
                          "attrs" => %( href="##{escape_html(loc.id)}"), "display_text" => escape_html(loc.text))
          end.join(", ")
          render_liquid("_element.html.liquid", "tag" => "span",
                                                "extra_attrs" => " class=\"index-locator\"", "content" => links)
        end

        def render_see(term)
          render_liquid("_element.html.liquid", "tag" => "div",
                                                "extra_attrs" => " class=\"index-see\"", "content" => "<em>see</em> #{escape_html(term)}")
        end

        def render_see_also(terms)
          text = terms.map { |t| escape_html(t) }.join(", ")
          render_liquid("_element.html.liquid", "tag" => "div",
                                                "extra_attrs" => " class=\"index-see-also\"", "content" => "<em>see also</em> #{text}")
        end

        def next_level(level)
          { "primary" => "secondary",
            "secondary" => "tertiary" }[level] || "tertiary"
        end
      end
    end
  end
end
