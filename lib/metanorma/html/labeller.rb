# frozen_string_literal: true

module Metanorma
  module Html
    # LADL labeling over the parsed document model: wraps the document
    # tree with the ladl adapter and labels it through the configured
    # profile, exposing per-element label lookups to the renderers.
    #
    # ladl is an optional render-time dependency: it is required lazily
    # here, so only the consumer that configures a labeling profile (a
    # taste or corpus harness) carries the gem.
    class Labeller
      attr_reader :result

      # @param profile_path [String] path to a LADL `.lml` profile
      # @param labels [Hash{String => String}] label vocabulary for the
      #   profile's `{key}` tokens (the host document's i18n table)
      # @param root [Object] the parsed document model root
      def initialize(profile_path, labels: {}, root:)
        require "ladl"
        profile = Ladl.load_profile(profile_path)
        content = Ladl::Adapters::MetanormaDocument.wrap(root)
        @result = Ladl::Runtime::Engine.new(profile, labels: labels).label(content)
      end

      # The local label for a model element (looked up by its id or
      # anchor), or nil when the element is unlabeled.
      def local_for(element)
        label_for(element, &:value)
      end

      # The global cross-reference label for a model element, or nil.
      def global_for(element)
        label_for(element, &:global_value)
      end

      private

      def label_for(element)
        id = element_id(element)
        label = id && @result.labels_by_element_id[id]
        label && yield(label)
      end

      def element_id(element)
        (element.respond_to?(:id) && element.id) ||
          (element.respond_to?(:anchor) && element.anchor)
      end
    end
  end
end
