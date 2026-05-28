# frozen_string_literal: true

module Metanorma
  module Html
    # Renders OimlDocument (OIML) components to HTML.
    # Extends IsoRenderer with OIML branding.
    class OimlRenderer < IsoRenderer
      def flavor_publishers(_doc_id)
        ["OIML"]
      end

      def flavor_publisher_name
        "OIML"
      end

      def publisher_logo_map
        {}
      end

      def theme
        @theme ||= Theme.load(:oiml)
      end
    end
  end
end
