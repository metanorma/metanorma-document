# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class BiblioEntryDrop < Liquid::Drop
        def initialize(attrs)
          @id = attrs[:id]
          @css_class = attrs[:css_class]
          @ordinal_html = attrs[:ordinal_html]
          @pubid_html = attrs[:pubid_html]
          @url = attrs[:url]
          @content_html = attrs[:content_html]
        end

        def id
          @id
        end

        def css_class
          @css_class
        end

        def ordinal_html
          @ordinal_html
        end

        def pubid_html
          @pubid_html
        end

        def url
          @url
        end

        def content_html
          @content_html
        end

        def has_ordinal
          !@ordinal_html.nil? && !@ordinal_html.empty?
        end

        def has_url
          !@url.nil? && !@url.empty?
        end
      end
    end
  end
end