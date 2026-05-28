# frozen_string_literal: true

module Metanorma
  module Html
    # Renders IetfDocument components to HTML.
    # Extends IsoRenderer with IETF/RFC branding.
    class IetfRenderer < IsoRenderer
      def flavor_publishers(_doc_id)
        ["IETF"]
      end

      def flavor_publisher_name
        "IETF"
      end

      def publisher_logo_map
        {}
      end

      def theme
        @theme ||= Theme.load(:ietf)
      end
    end
  end
end
