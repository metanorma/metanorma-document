# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Inline
        module RichHtmlRenderer
          RENDERERS = {
            Metanorma::Document::Components::Inline::EmRawElement => "em",
            Metanorma::Document::Components::Inline::StrongRawElement => "strong",
            Metanorma::Document::Components::Inline::SubElement => "sub",
            Metanorma::Document::Components::Inline::SupElement => "sup",
            Metanorma::Document::Components::Inline::TtElement => "code",
            Metanorma::Document::Components::TextElements::UnderlineElement => "u",
            Metanorma::Document::Components::TextElements::StrikeElement => "s",
            Metanorma::Document::Components::Inline::SmallCapElement => "span",
            Metanorma::Document::Components::Inline::Bcp14Element => "span",
            Metanorma::Document::Components::Inline::StemInlineElement => :for_stem,
            Metanorma::Document::Components::TextElements::StemElement => :for_stem,
            Metanorma::Document::Components::Inline::XrefElement => :for_xref,
            Metanorma::Document::Components::Inline::LinkElement => :for_link,
            Metanorma::Document::Components::Inline::ErefElement => :for_eref,
            Metanorma::Document::Components::Inline::FnElement => :for_fn,
            Metanorma::Document::Components::Inline::ConceptElement => "span",
            Metanorma::Document::Components::Inline::SpanElement => :for_span,
            Metanorma::Document::Components::Inline::BrElement => :for_br,
          }.freeze

          def self.extract(element)
            return "" unless element
            return CGI.escapeHTML(element.to_s) unless element.is_a?(Lutaml::Model::Serializable)

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
            if renderer.nil?
              extract(element)
            elsif renderer.is_a?(Symbol)
              public_send(renderer, element)
            else
              "<#{renderer}>#{extract(element)}</#{renderer}>"
            end
          end

          def self.for_br(_element)
            "<br>"
          end

          def self.for_stem(element)
            math = SafeAttr.read(element, :math)
            return TextExtractor.extract_element_text(element) unless math

            mathml = MathUtil.mathml_from_math(math)
              .sub(/\s*xmlns(:\w+)?="[^"]*"\s*/, " ")
              .gsub(/\s+/, " ")
              .strip
            %(<span class="inline-math">#{mathml}</span>)
          end

          def self.for_xref(element)
            target = SafeAttr.read(element, :target) || ""
            label = TextExtractor.extract_formatted_text(element)
            label = target if label.strip.empty?
            %{<a href="##{CGI.escapeHTML(target)}">#{CGI.escapeHTML(label)}</a>}
          end

          def self.for_link(element)
            href = SafeAttr.read(element, :target) || SafeAttr.read(element, :href) || ""
            label = TextExtractor.extract_formatted_text(element)
            %{<a href="#{CGI.escapeHTML(href)}">#{CGI.escapeHTML(label)}</a>}
          end

          def self.for_eref(element)
            citeas = SafeAttr.read(element, :citeas) || ""
            label = TextExtractor.extract_formatted_text(element)
            %{<a class="eref" cite="#{CGI.escapeHTML(citeas)}">#{CGI.escapeHTML(label)}</a>}
          end

          def self.for_fn(element)
            reference = SafeAttr.read(element, :reference) || ""
            %{<sup class="footnote-inline">#{CGI.escapeHTML(reference)}</sup>}
          end

          def self.for_span(element)
            cls = SafeAttr.read(element, :class_attr)
            cls_attr = cls ? %( class="#{CGI.escapeHTML(cls)}") : ""
            inner = extract(element)
            "<span#{cls_attr}>#{inner}</span>"
          end
        end
      end
    end
  end
end
