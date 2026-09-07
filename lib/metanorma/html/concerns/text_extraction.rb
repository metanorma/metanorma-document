# frozen_string_literal: true

module Metanorma
  module Html
    module Concerns
      # Plain-text extraction from model nodes, mixed into BaseRenderer.
      # Used wherever rendered output needs a text-only form (titles,
      # labels, captions, ToC entries). Walks `element_order` and typed
      # attributes directly on the model — never strips tags from
      # rendered HTML.
      module TextExtraction
        # Invisible MathML operators and joiners (word joiner, invisible
        # times / function application, zero-width space): markup, not
        # display text.
        INVISIBLE_MATH_CHARS = "\u2060\u2061\u2062\u2063\u2064\u200b"

        # Rendered fmt-* twins never contribute plain text alongside
        # their semantic siblings — the pair linearizes one logical
        # content (#51). Sibling-keyed twins skip only when the
        # semantic element parsed; the always-skipped set are
        # whole-block re-renderings (rendered to the exclusion of the
        # semantic children by the overlay's own contract).
        RENDERED_TWIN_SIBLING = {
          "fmt-stem" => :stem,
          "fmt-eref" => :eref,
          "fmt-origin" => :origin,
        }.freeze
        RENDERED_TWIN_ALWAYS_SKIP = %w[
          fmt-figure fmt-ul fmt-ol fmt-source fmt-date-inline
        ].freeze

        # The quoted unitsml(...) macro reference names a unit symbol;
        # its linear form is the symbol itself ("unitsml(mV/V)" ->
        # "mV/V"). One nesting level for grouped exponents.
        UNITSML_MACRO =
          /"?unitsml\(([^()]*(?:\([^()]*\)[^()]*)*)\)"?/

        def extract_plain_text(node)
          return node.to_s if node.is_a?(String)
          return extract_text_value(node).to_s unless node.is_a?(Lutaml::Model::Serializable)

          # nil = not a populated stem (e.g. a semx autonum slice also
          # declares these attributes): fall through to the walk.
          stem = stem_text(node)
          return stem unless stem.nil?

          parts = ordered_content_parts(node)
          if parts.join.strip.empty?
            t = safe_attr(node, :text)
            parts << (t.is_a?(Array) ? t.join : t.to_s) if t
          end

          parts.join.strip.gsub(" ", " ")
        end

        def ordered_content_parts(node)
          return [] unless node.element_order.is_a?(Array)

          xml_mapping = node.class.mappings_for(:xml, node.lutaml_register)
          return [] unless xml_mapping

          element_to_attr =
            Renderers::ElementOrderTraversal.element_to_attr_map(xml_mapping)

          parts = []
          indices = Hash.new(0)
          node.element_order.each do |el|
            next unless el.is_a?(Lutaml::Xml::Element)

            if el.text?
              parts << el.text_content.to_s
            elsif el.name == "tab"
              parts << " "
            # rubocop:disable Lint/DuplicateBranch
            elsif el.name == "br"
              parts << " "
            # rubocop:enable Lint/DuplicateBranch
            elsif el.name == "rt"
              # ruby annotation (pronunciation) rides along the base
              # text, it is not content: display text is the base alone
              next
            elsif el.element?
              next if rendered_twin?(el.name, node)

              attr_name = element_to_attr[el.name]
              if attr_name
                coll = node.public_send(attr_name)
                obj = if coll.is_a?(Array)
                        idx = indices[attr_name]
                        indices[attr_name] += 1
                        coll[idx]
                      else
                        coll
                      end
                text = extract_plain_text(obj)
                parts << (text.empty? ? " " : text)
              elsif el.name == "span"
                parts << " "
              end
            end
          end
          parts
        end

        # A stem (or a semx slice of one) carries up to three
        # serializations of a single expression: the AsciiMath source,
        # the MathML rendering, the LaTeX source. Linearizing more than
        # one concatenates duplicates — "30003000", 'n LCn_{"LC"}'
        # (#51). Preference: the source linear form, then the MathML
        # token walk. Returns nil when no form is populated — the node
        # is then not stem-shaped content (an empty semx slice), and
        # the caller falls back to the element_order walk.
        def stem_text(stem)
          return nil unless math_carrier?(stem)

          populated = false
          %i[asciimath math latexmath].each do |form|
            value = safe_attr(stem, form)
            next if value.nil? || (value.respond_to?(:empty?) && value.empty?)

            populated = true
            text = if form == :math
                     Array(value).map { |m| extract_plain_text(m) }.join(" ")
                   else
                     extract_text_value(value)
                   end
            text = normalize_math_text(text)
            return text unless text.empty?
          end
          populated ? "" : nil
        end

        # Duck-typed stem check: any model declaring both an asciimath
        # and a math attribute serializes one expression in multiple
        # forms (StemInlineElement, StemElement, SemxElement).
        def math_carrier?(node)
          attrs = node.class.attributes
          attrs.key?(:asciimath) && attrs.key?(:math)
        end

        def rendered_twin?(name, node)
          return true if RENDERED_TWIN_ALWAYS_SKIP.include?(name)

          sibling = RENDERED_TWIN_SIBLING[name] or return false

          values = safe_attr(node, sibling)
          siblings = Array(values).compact
          return false if siblings.empty?

          # The semantic form is authoritative when it carries text; an
          # empty semantic element defers its label to the rendered
          # twin (the overlay resolves empty erefs into fmt-eref).
          siblings.any? { |s| !extract_plain_text(s).to_s.strip.empty? }
        end

        def normalize_math_text(text)
          text.to_s
            .tr(INVISIBLE_MATH_CHARS, "")
            .gsub(UNITSML_MACRO) { Regexp.last_match(1) }
            .strip
        end

        def extract_text_value(val)
          return nil if val.nil?
          return val if val.is_a?(String)

          if val.is_a?(Array)
            val.map { |v| extract_text_value(v) }.join
          elsif val.is_a?(Lutaml::Model::Serializable)
            c = safe_attr(val, :content)
            if c && !c.equal?(val)
              extract_text_value(c)
            else
              t = safe_attr(val, :text)
              if t
                extract_text_value(t)
              else
                v = safe_attr(val, :value)
                if v
                  extract_text_value(v)
                else
                  val.to_s
                end
              end
            end
          else
            val.to_s
          end
        end
      end
    end
  end
end
