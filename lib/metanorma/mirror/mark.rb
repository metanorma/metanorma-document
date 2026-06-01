# frozen_string_literal: true

module Metanorma
  module Mirror
    class Mark
      PM_TYPE = "mark"

      attr_accessor :type, :attrs

      def initialize(type: nil, attrs: {})
        @type = type || self.class::PM_TYPE
        @attrs = attrs || {}
      end

      def to_h
        result = { "type" => type }
        unless attrs.nil? || attrs.empty?
          result["attrs"] =
            attrs.transform_keys(&:to_s)
        end
        result
      end

      alias to_hash to_h

      def to_json(**options)
        to_h.to_json(options)
      end

      def self.from_h(hash)
        return nil unless hash

        type = hash["type"]
        attrs = hash["attrs"] || {}
        mark_class = MARKS[type] || Mark
        mark_class.new(attrs: attrs.transform_keys(&:to_sym))
      end

      MARKS = {} # rubocop:disable Style/MutableConstant

      class Emphasis < Mark
        PM_TYPE = "emphasis"
      end

      class Strong < Mark
        PM_TYPE = "strong"
      end

      class Subscript < Mark
        PM_TYPE = "subscript"
      end

      class Superscript < Mark
        PM_TYPE = "superscript"
      end

      class Code < Mark
        PM_TYPE = "code"
      end

      class Underline < Mark
        PM_TYPE = "underline"
      end

      class Strike < Mark
        PM_TYPE = "strike"
      end

      class SmallCap < Mark
        PM_TYPE = "smallcap"
      end

      class Link < Mark
        PM_TYPE = "link"
      end

      class Xref < Mark
        PM_TYPE = "xref"
      end

      class Eref < Mark
        PM_TYPE = "eref"
      end

      class Footnote < Mark
        PM_TYPE = "footnote"
      end

      class Stem < Mark
        PM_TYPE = "stem"
      end

      class Concept < Mark
        PM_TYPE = "concept"
      end

      class Bcp14 < Mark
        PM_TYPE = "bcp14"
      end

      class Span < Mark
        PM_TYPE = "span"
      end

      # Auto-register all subclasses by PM_TYPE
      constants.each do |name|
        klass = const_get(name)
        next unless klass.is_a?(Class) && klass < Mark && klass::PM_TYPE != "mark"

        MARKS[klass::PM_TYPE] = klass
      end
    end
  end
end
