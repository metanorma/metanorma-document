# frozen_string_literal: true

module Metanorma
  module Mko
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
        def call(element)
          return EXTRACTOR.extract_plain_text(element).to_s
                 .gsub(/\s+/, " ").strip unless element.is_a?(Array)

          element.map { |e| call(e) }.reject(&:empty?).join(" ")
        end
      end
    end
  end
end
