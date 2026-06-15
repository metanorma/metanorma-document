# frozen_string_literal: true

module Metanorma
  module Mirror
    class HandlerResult
      attr_reader :nodes

      def self.none
        new(nil, concat: false)
      end

      def initialize(nodes, concat: false)
        @nodes = nodes
        @concat = concat
      end

      def none?
        @nodes.nil?
      end

      def concat?
        @concat
      end

      def append_to(content)
        return content if none?

        if concat?
          content.concat(Array(@nodes))
        else
          content << @nodes
        end
        content
      end
    end
  end
end
