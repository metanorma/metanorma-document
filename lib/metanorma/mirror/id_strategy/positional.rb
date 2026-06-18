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
        @categories = {}

        class << self
          # Registry of Metanorma model classes → positional-ID category
          # (:section, :annex, :figure, :table). Adding new flavors or new
          # model types requires only a new register_category call — no
          # edits to derive/element_category (OCP).
          def categories
            @categories
          end

          def register_category(model_class, category)
            categories[model_class] = category
            self
          end

          def unregister_category(model_class)
            categories.delete(model_class)
            self
          end

          def category_for(element)
            return categories[element.class] if categories.key?(element.class)

            categories.each do |klass, category|
              return category if element.is_a?(klass)
            end
            nil
          end
        end

        register_category Metanorma::StandardDocument::Sections::ClauseSection,
                          :section
        register_category Metanorma::StandardDocument::Sections::ContentSection,
                          :section
        register_category Metanorma::StandardDocument::Sections::TermsSection,
                          :section
        register_category Metanorma::StandardDocument::Sections::DefinitionSection,
                          :section
        register_category Metanorma::StandardDocument::Sections::AnnexSection,
                          :annex
        register_category Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
                          :figure
        register_category Metanorma::Document::Components::Tables::TableBlock,
                          :table

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
          translate_targets(document)
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

          case self.class.category_for(element)
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

        def translate_targets(node)
          case node
          when Model::Text
            node.marks.each { |mark| translate_mark_target(mark) }
          when Model::Container
            node.content.each { |child| translate_targets(child) }
          end
        end

        def translate_mark_target(mark)
          return unless mark.type == "xref"

          target = mark["target"]
          return unless target

          translated = @id_map[target]
          mark["target"] = translated if translated
        end
      end
    end
  end
end
