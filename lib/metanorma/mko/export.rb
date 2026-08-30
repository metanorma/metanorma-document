# frozen_string_literal: true

module Metanorma
  module Mko
    # The value an export returns: the bundle path (String-ducktyped,
        # so existing callers keep working) plus the projection Result,
        # so composite exporters (collections, alignments) derive from
    # the same truth the bundle was written from — never by reading
    # their own output back.
    class Export
      attr_reader :path, :result

      def initialize(path, result)
        @path = path
        @result = result
      end

      def to_s
        @path.to_s
      end

      def to_str
        @path.to_s
      end
    end
  end
end
