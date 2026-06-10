# frozen_string_literal: true

module Metanorma
  module Mirror
    module IdStrategy
      # Assign positional IDs (sec-X.Y.Z, table-N, fig-N, anx-X) to elements
      # that have UUID IDs. Elements with author-assigned explicit IDs are
      # preserved. Cross-reference targets are translated to use the new IDs.
      #
      # Positional IDs are derived from the element's resolved section number
      # (the "number" attribute on the presentation XML element), which
      # represents the document's structural position.
      #
      # Example:
      #   UUID element with number "5.4" → id: "sec-5.4"
      #   UUID element with number "A.2"  → id: "anx-A.2"
      #   Explicit id "sec-3.1.3.4"       → id: "sec-3.1.3.4" (unchanged)
      class Positional < Base
        def initialize
          @id_map = {}
        end

        def assign_id(element)
          raw = raw_id(element)
          return raw unless uuid?(raw)

          positional = derive(element)
          return raw unless positional

          @id_map[raw] = positional
          positional
        end

        def finalize!(document)
          translate_targets!(document)
          document
        end

        private

        def raw_id(element)
          SafeAttr.read(element, :id)
        end

        def uuid?(id)
          id&.start_with?("_")
        end

        def derive(element)
          number = extract_number(element)
          return nil unless number && !number.strip.empty?

          case element_category(element)
          when :section
            number.match?(/\A[\d.]+\z/) ? "sec-#{number}" : nil
          when :annex
            number.match?(/\A[A-Z]/) ? "anx-#{number}" : nil
          when :figure
            "fig-#{number}"
          when :table
            "table-#{number}"
          end
        end

        def extract_number(element)
          number = SafeAttr.read(element, :number)
          return number if number && !number.strip.empty?

          attrs = element.class.attributes
          return nil unless attrs.key?(:fmt_title)

          fmt_title = element.fmt_title
          return nil unless fmt_title

          parts = collect_autonum_text(fmt_title)
          parts.empty? ? nil : parts.join(".")
        end

        def collect_autonum_text(node)
          parts = []
          attrs = node.class.attributes

          if attrs.key?(:semx) && node.semx
            node.semx.each do |s|
              next unless s.element_attr == "autonum"

              text = s.text&.join
              parts << text if text && !text.empty?
            end
          end

          if attrs.key?(:span) && node.span
            node.span.each { |sp| parts.concat(collect_autonum_text(sp)) }
          end

          parts
        end

        def element_category(element)
          case element
          when Metanorma::StandardDocument::Sections::ClauseSection,
               Metanorma::StandardDocument::Sections::ContentSection,
               Metanorma::StandardDocument::Sections::TermsSection,
               Metanorma::StandardDocument::Sections::DefinitionSection
            :section
          when Metanorma::StandardDocument::Sections::AnnexSection
            :annex
          when Metanorma::Document::Components::AncillaryBlocks::FigureBlock
            :figure
          when Metanorma::Document::Components::Tables::TableBlock
            :table
          end
        end

        def translate_targets!(node)
          return unless node.is_a?(Hash)

          Array(node["content"]).each do |child|
            next unless child.is_a?(Hash)

            if child["type"] == "text"
              Array(child["marks"]).each do |mark|
                next unless mark["type"] == "xref"

                target = mark.dig("attrs", "target")
                mark["attrs"] ||= {}
                mark["attrs"]["target"] = @id_map[target] || target if target
              end
            end
            translate_targets!(child)
          end
        end
      end
    end
  end
end
