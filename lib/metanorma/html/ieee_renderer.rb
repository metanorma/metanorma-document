# frozen_string_literal: true

module Metanorma
  module Html
    # Renders IeeeDocument components to HTML.
    # Extends IsoRenderer with IEEE branding.
    class IeeeRenderer < IsoRenderer
      def flavor_publishers(_doc_id)
        ["IEEE"]
      end

      def flavor_publisher_name
        "IEEE"
      end

      def publisher_logo_map
        {}
      end

      def theme
        @theme ||= Theme.load(:ieee)
      end
    end
  end
end
