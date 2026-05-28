# frozen_string_literal: true

module Metanorma
  module Html
    # IEC brand: #0061a9 blue from logo
    class IecRenderer < IsoRenderer
      def flavor_publishers(_doc_id)
        ["IEC"]
      end

      def flavor_publisher_name
        "IEC"
      end

      def publisher_logo_map
        { "IEC" => "iec-logo.svg" }
      end

      def theme
        @theme ||= Theme.load(:iec)
      end
    end
  end
end
