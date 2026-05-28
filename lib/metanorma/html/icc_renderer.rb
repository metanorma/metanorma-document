# frozen_string_literal: true

module Metanorma
  module Html
    # Renders ICC (International Color Consortium) taste documents to HTML.
    # ICC brand: color management — dark charcoal + steel blue + warm gray
    class IccRenderer < IsoRenderer
      def flavor_publishers(_doc_id)
        ["ICC"]
      end

      def flavor_publisher_name
        "ICC"
      end

      def publisher_logo_map
        {}
      end

      def theme
        @theme ||= Theme.load(:icc)
      end
    end
  end
end
