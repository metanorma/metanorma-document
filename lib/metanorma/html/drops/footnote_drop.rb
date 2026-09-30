# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class FootnoteDrop < Liquid::Drop
        def initialize(entry, content_html)
          @entry = entry
          @content_html = content_html
        end

        def number
          @entry.number
        end

        def label
          @entry.fmt_label.to_s.empty? ? @entry.reference : @entry.fmt_label
        end

        def content_html
          @content_html
        end
      end
    end
  end
end
