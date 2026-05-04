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

        def reference
          @entry.reference
        end

        def content_html
          @content_html
        end
      end
    end
  end
end
