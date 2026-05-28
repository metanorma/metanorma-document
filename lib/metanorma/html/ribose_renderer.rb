# frozen_string_literal: true

module Metanorma
  module Html
    # Renders RiboseDocument components to HTML.
    # Extends IsoRenderer with Ribose branding.
    class RiboseRenderer < IsoRenderer
      def flavor_publishers(_doc_id)
        ["Ribose"]
      end

      def flavor_publisher_name
        "Ribose"
      end

      def publisher_logo_map
        {}
      end

      def theme
        @theme ||= Theme.load(:ribose)
      end
    end
  end
end
