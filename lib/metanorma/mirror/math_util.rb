# frozen_string_literal: true

module Metanorma
  module Mirror
    # MathUtil is the single home for math-content extraction helpers.
    #
    # These helpers convert mathML XML objects into strings (stripped of
    # XML declarations) and extract asciimath from stem elements. They
    # are used by handlers and renderers that need to carry math content
    # through the mirror pipeline.
    module MathUtil
      STRIP_XML_DECL_PATTERN = /\A<\?xml[^?]*\?>\s?/
      private_constant :STRIP_XML_DECL_PATTERN

      def self.strip_xml_decl(math_xml)
        math_xml.sub(STRIP_XML_DECL_PATTERN, "")
      end

      def self.mathml_from_math(math)
        xml = math.is_a?(Array) ? math.map(&:to_xml).join : math.to_xml
        strip_xml_decl(xml)
      end

      # Extract asciimath text from a stem element. Returns nil if no
      # asciimath is present.
      def self.asciimath_from_stem(stem)
        asciimath = SafeAttr.read(stem, :asciimath)
        return nil unless asciimath.is_a?(Array)

        parts = asciimath.filter_map do |a|
          next a if a.is_a?(String)
          next SafeAttr.read(a, :text).to_s if a.is_a?(Lutaml::Model::Serializable)

          nil
        end
        joined = parts.join.strip
        joined.empty? ? nil : joined
      end

      # Best-effort plain-text extraction from a stem element. Tries
      # asciimath first; falls back to SafeAttr :text.
      def self.text_from_stem(stem)
        asciimath = asciimath_from_stem(stem)
        return asciimath if asciimath

        text = SafeAttr.read(stem, :text)
        return text.to_s if text.is_a?(String) && !text.strip.empty?

        ""
      end
    end
  end
end
