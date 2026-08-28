# frozen_string_literal: true

module Metanorma
  module Document
    # Extracts plain display text from typed model elements. Delegates to
    # the canonical model-walking extractor shared with the HTML renderer
    # (element_order resolution + typed attributes) — never Nokogiri over
    # XML, never regex over HTML.
    module PlainText
      class Extractor
        include Metanorma::Html::Concerns::TextExtraction

        def safe_attr(obj, name)
          return nil unless obj.is_a?(Lutaml::Model::Serializable) &&
            obj.class.attributes.key?(name)

          obj.public_send(name)
        end
      end

      EXTRACTOR = Extractor.new

      class << self
        # Whitespace-squashed on the way out: document text carries
        # non-breaking spaces (U+00A0) that break exact matching; Ruby's
        # \s is ASCII-only, so use the Unicode-aware POSIX class.
        def call(element)
          return squash(EXTRACTOR.extract_plain_text(element).to_s) unless element.is_a?(Array)

          element.map { |e| call(e) }.reject(&:empty?).join(" ")
        end

        def squash(text)
          text.gsub(/[[:space:]]+/, " ").strip
        end
      end
    end
  end
end
