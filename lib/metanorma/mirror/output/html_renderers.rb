# frozen_string_literal: true

require "nokogiri"

module Metanorma
  module Mirror
    module Output
      module HtmlRenderers
        autoload :StructuralRenderers, "#{__dir__}/html_renderers/structural_renderers"
        autoload :SectionRenderers, "#{__dir__}/html_renderers/section_renderers"
        autoload :BlockRenderers, "#{__dir__}/html_renderers/block_renderers"
        autoload :ListRenderers, "#{__dir__}/html_renderers/list_renderers"
        autoload :TableRenderers, "#{__dir__}/html_renderers/table_renderers"
        autoload :InlineRenderer, "#{__dir__}/html_renderers/inline_renderer"
        autoload :MarkRenderers, "#{__dir__}/html_renderers/mark_renderers"

        MODULES = %i[
          StructuralRenderers
          SectionRenderers
          BlockRenderers
          ListRenderers
          TableRenderers
          InlineRenderer
          MarkRenderers
        ].freeze

        def self.register_all(renderer_class)
          MODULES.each { |mod_name| const_get(mod_name).register(renderer_class) }
        end

        # Build a single HTML root element via Nokogiri::HTML4::Builder.
        # Returns the rendered HTML string.
        def self.build(&)
          builder = Nokogiri::HTML4::Builder.new(&)
          builder.doc.root.to_html
        end

        # Build an HTML fragment (multiple roots permitted) via
        # Nokogiri::HTML4::Builder. Returns the rendered HTML string.
        def self.build_fragment(&)
          fragment = Nokogiri::HTML4::DocumentFragment.parse("")
          Nokogiri::HTML4::Builder.with(fragment, &)
          fragment.to_html
        end

        # Embed a pre-rendered HTML string under the current builder node
        # without re-escaping.
        def self.embed(doc, html_string)
          return if html_string.nil? || html_string.to_s.empty?

          doc << Nokogiri::HTML4::DocumentFragment.parse(html_string.to_s)
        end

        # Wrap a pre-rendered HTML string in a tag. Used by mark handlers.
        def self.wrap(tag, inner_html, **attrs)
          Nokogiri::HTML4::Builder.new do |doc|
            doc.public_send(tag, attrs) { doc.parent.inner_html = inner_html.to_s }
          end.doc.root.to_html
        end

        # Escape text for safe inclusion in HTML body content.
        def self.escape_text(text)
          return "" unless text

          CGI.escapeHTML(text.to_s)
        end
      end
    end
  end
end
