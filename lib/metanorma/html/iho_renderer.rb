# frozen_string_literal: true

module Metanorma
  module Html
    # IHO brand: #00AAA9 teal + #05164D navy + #FEDC5B gold from logo
    class IhoRenderer < IsoRenderer
      def flavor_publishers(_doc_id)
        ["IHO"]
      end

      def flavor_publisher_name
        "IHO"
      end

      def publisher_logo_map
        { "IHO" => "iho-logo.svg" }
      end

      def theme
        @theme ||= Theme.load(:iho)
      end
    end
  end
end
