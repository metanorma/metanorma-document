# frozen_string_literal: true

module Metanorma
  module Html
    # Renders PDF Association (PDFA) taste documents to HTML.
    # PDFA brand: #cf9c1d gold + #d03544 red + #4992b2 steel blue from logo
    class PdfaRenderer < IsoRenderer
      def flavor_publishers(_doc_id)
        ["PDF Association"]
      end

      def flavor_publisher_name
        "PDF Association"
      end

      def publisher_logo_map
        { "PDF Association" => "pdfa-logo.svg" }
      end

      def theme
        @theme ||= Theme.load(:pdfa)
      end
    end
  end
end
