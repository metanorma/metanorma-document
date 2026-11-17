# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      # Lazy rendering prevents unused template fields from registering
      # footnotes or TOC entries as a side effect.
      class FrontMatterDrop < Liquid::Drop
        def initialize(renderer, document)
          @renderer = renderer
          @document = document
          @statements = {}
        end

        def copyright_html = statement_html(:copyright_statement)
        def license_html = statement_html(:license_statement)
        def legal_html = statement_html(:legal_statement)
        def feedback_html = statement_html(:feedback_statement)

        private

        def statement_html(name)
          @statements[name] ||= Array(@renderer.safe_attr(@document.boilerplate, name)).map do |node|
            @renderer.render(node).to_s
          end.join
        end
      end
    end
  end
end
