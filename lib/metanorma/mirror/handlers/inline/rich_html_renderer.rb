# frozen_string_literal: true

require "nokogiri"

module Metanorma
  module Mirror
    module Handlers
      module Inline
        # Renders inline Metanorma elements as HTML strings. Used when an HTML
        # representation of inline content is required (e.g., attribute values,
        # fallback rendering). All HTML construction goes through
        # Nokogiri::HTML5::Builder to guarantee well-formed, escaped output.
        module RichHtmlRenderer
          RENDERERS = {
            Metanorma::Document::Components::Inline::EmRawElement => ->(el) {
              wrap { |d| d.em { d << raw(extract(el)) } }
            },
            Metanorma::Document::Components::Inline::StrongRawElement => ->(el) {
              wrap { |d| d.strong { d << raw(extract(el)) } }
            },
            Metanorma::Document::Components::Inline::SubElement => ->(el) {
              wrap { |d| d.sub { d << raw(extract(el)) } }
            },
            Metanorma::Document::Components::Inline::SupElement => ->(el) {
              wrap { |d| d.sup { d << raw(extract(el)) } }
            },
            Metanorma::Document::Components::Inline::TtElement => ->(el) {
              wrap { |d| d.code { d << raw(extract(el)) } }
            },
            Metanorma::Document::Components::TextElements::UnderlineElement => ->(el) {
              wrap { |d| d.u { d << raw(extract(el)) } }
            },
            Metanorma::Document::Components::TextElements::StrikeElement => ->(el) {
              wrap { |d| d.s { d << raw(extract(el)) } }
            },
            Metanorma::Document::Components::Inline::SmallCapElement => ->(el) {
              wrap { |d| d.span { d << raw(extract(el)) } }
            },
            Metanorma::Document::Components::Inline::Bcp14Element => ->(el) {
              wrap { |d| d.span { d << raw(extract(el)) } }
            },
            Metanorma::Document::Components::Inline::StemInlineElement => ->(el) {
              for_stem(el)
            },
            Metanorma::Document::Components::TextElements::StemElement => ->(el) {
              for_stem(el)
            },
            Metanorma::Document::Components::Inline::XrefElement => ->(el) {
              for_xref(el)
            },
            Metanorma::Document::Components::Inline::LinkElement => ->(el) {
              for_link(el)
            },
            Metanorma::Document::Components::Inline::ErefElement => ->(el) {
              for_eref(el)
            },
            Metanorma::Document::Components::Inline::FnElement => ->(el) {
              for_fn(el)
            },
            Metanorma::Document::Components::Inline::ConceptElement => ->(el) {
              wrap { |d| d.span(class: "concept") { d << raw(extract(el)) } }
            },
            Metanorma::Document::Components::Inline::SpanElement => ->(el) {
              for_span(el)
            },
            Metanorma::Document::Components::Inline::BrElement => ->(_el) {
              wrap(&:br)
            },
          }.freeze

          def self.extract(element)
            return "" unless element

            unless element.is_a?(Lutaml::Model::Serializable)
              return CGI.escapeHTML(element.to_s)
            end

            parts = []
            element.each_mixed_content { |node| parts << render_node(node) }
            result = parts.join.strip
            result.empty? ? TextExtractor.extract_element_text(element) : result
          end

          def self.render_node(node)
            case node
            when String
              CGI.escapeHTML(node)
            when Lutaml::Model::Serializable
              render_element(node)
            else
              ""
            end
          end

          def self.render_element(element)
            renderer = RENDERERS[element.class]
            renderer ? renderer.call(element) : extract(element)
          end

          def self.for_stem(element)
            math = SafeAttr.read(element, :math)
            return TextExtractor.extract_element_text(element) unless math

            mathml = MathUtil.mathml_from_math(math)
              .sub(/\s*xmlns(:\w+)?="[^"]*"\s*/, " ")
              .gsub(/\s+/, " ")
              .strip
            wrap { |d| d.span(class: "inline-math") { d << raw(mathml) } }
          end

          def self.for_xref(element)
            target = SafeAttr.read(element, :target) || ""
            label = TextExtractor.extract_formatted_text(element)
            label = target if label.strip.empty?
            wrap { |d| d.a(href: "##{target}") { d.text label } }
          end

          def self.for_link(element)
            href = SafeAttr.read(element, :target) || SafeAttr.read(element, :href) || ""
            label = TextExtractor.extract_formatted_text(element)
            wrap { |d| d.a(href: href) { d.text label } }
          end

          def self.for_eref(element)
            citeas = SafeAttr.read(element, :citeas) || ""
            label = TextExtractor.extract_formatted_text(element)
            wrap { |d| d.a(class: "eref", cite: citeas) { d.text label } }
          end

          def self.for_fn(element)
            reference = SafeAttr.read(element, :reference) || ""
            wrap { |d| d.sup(class: "footnote-inline") { d.text reference } }
          end

          def self.for_span(element)
            cls = SafeAttr.read(element, :class_attr)
            inner = extract(element)
            wrap do |d|
              if cls
                d.span(class: cls) { d << raw(inner) }
              else
                d.span { d << raw(inner) }
              end
            end
          end

          def self.wrap(&)
            Nokogiri::HTML5::Builder.new(&).doc.root.to_html
          end

          def self.raw(html_string)
            Nokogiri::HTML5::DocumentFragment.parse(html_string.to_s)
          end
        end
      end
    end
  end
end
