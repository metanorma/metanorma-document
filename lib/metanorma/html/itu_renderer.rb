# frozen_string_literal: true

module Metanorma
  module Html
    # ITU brand: #0e99d5 blue from logo
    class ItuRenderer < IsoRenderer
      def flavor_publishers(_doc_id)
        ["ITU"]
      end

      def flavor_publisher_name
        "ITU"
      end

      def publisher_logo_map
        { "ITU" => "itu-logo.svg" }
      end

      def theme
        @theme ||= Theme.load(:itu)
      end
    end
  end
end
