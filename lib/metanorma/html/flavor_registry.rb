# frozen_string_literal: true

module Metanorma
  module Html
    # Registry of known flavors. Queried by:
    # - Generator — to pick the renderer for a document
    # - BaseRenderer — to resolve flavor_name for theme loading
    # - PubidRenderer — to resolve the Pubid module
    #
    # Single source of truth for flavor identity. Adding a flavor is
    # one Flavor entry via #register.
    class FlavorRegistry
      include Enumerable

      def initialize
        @flavors = []
      end

      def register(flavor)
        @flavors << flavor
        self
      end

      def each(&)
        @flavors.each(&)
      end

      # Returns the most-specific Flavor whose model_class matches the
      # given document class (by ancestry). Most-specific = registered
      # last. We scan in reverse so general flavors (registered first)
      # only match if no more specific flavor does.
      def find_for(document_class)
        @flavors.reverse_each.find { |f| f.matches?(document_class) }
      end

      def name_for(document_class)
        find_for(document_class)&.name
      end

      def renderer_for(document_class)
        find_for(document_class)&.renderer_class
      end

      def pubid_module_for(document_class)
        find_for(document_class)&.pubid_module_const
      end
    end
  end
end
