# frozen_string_literal: true

module Metanorma
  module Html
    # Renders CcDocument (CalConnect) components to HTML.
    # Extends IsoRenderer with CalConnect branding.
    class CcRenderer < IsoRenderer
      def flavor_publishers(_doc_id)
        ["CalConnect"]
      end

      def flavor_publisher_name
        "CalConnect"
      end

      def publisher_logo_map
        {}
      end

      def theme
        @theme ||= Theme.load(:cc)
      end
    end
  end
end
