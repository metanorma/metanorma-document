# frozen_string_literal: true

require "glossarist"
require "relaton/bib"
require "pubid"

module Metanorma
  module Document
    # Decomposition of a typed document model into the native object
    # models of the Metanorma ecosystem: Glossarist concepts from term
    # entries, Relaton bibdata from the bibliographic record, Pubid
    # identifiers from document identifiers.
    #
    # This is a MODEL-layer capability, available to any consumer; the
    # MKO serialization is one of them. All objects returned are the
    # native gems' own classes, serialized by their own frameworks —
    # never re-flattened into a parallel schema. Traversal dispatches on
    # class/attribute declarations only (both model trees; zero flavor
    # knowledge).
    module NativeModels
      class << self
        include Metanorma::Document::ModelAccess

        # Term entries as Glossarist::Concept objects (native to_json).
        # lang/date are derivable defaults, overridable by callers that
        # already computed them.
        def glossarist_concepts(root, lang: nil, date: nil)
          lang ||= first_lang(root)
          date ||= published_on(root)
          entries(root).map do |term|
            concept_for(term, lang: lang, date: date)
          end
        end

        # The bibliographic record as a native Relaton::Bib item. The
        # model's bibdata is serialized to Relaton XML (its native
        # schema) and parsed back by the relaton monogem — both
        # directions are framework serialization.
        def relaton_bibdata(root)
          bib = val(root, :bibdata)
          return nil unless bib

          ::Relaton::Bib::Item.from_xml(bib.to_xml)
        end

        # Document identifiers parsed by the pubid monogem. Each entry
        # carries the original text, its primary flag, and the native
        # Pubid::Identifier (nil when no pubid flavor covers it).
        def pubid_identifiers(root)
          bib = val(root, :bibdata)
          docids(bib).map do |d|
            text = docid_text(d)
            { original: text, type: val(d, :type),
              primary: val(d, :primary), pubid: parse_pubid(text) }
          end
        end

        # One bibliography entry: the reference unit's key, the citeas
        # string, and the NATIVE objects behind the cited document — a
        # Relaton::Bib item and, when a pubid flavor covers it, a
        # Pubid::Identifier. This is what makes citation edges resolvable
        # objects instead of dangling strings.
        class BibliographyEntry
          attr_reader :key, :citeas, :pubid, :item

          def initialize(key:, citeas:, pubid:, item:)
            @key = key
            @citeas = citeas
            @pubid = pubid
            @item = item
          end
        end

        # Bibliography entries as native Relaton items. Every <bibitem>
        # in every references section round-trips: model XML (the
        # Relaton schema) parsed back by the relaton monogem.
        def relaton_bibliography(root)
          entries = []
          Array(val(root, :bibliography)).each do |bib_section|
            vals(bib_section, :references).each do |refs|
              items = vals(refs, :bibitem)
              items = vals(refs, :references) if items.empty?
              items.each { |i| entries << bibliography_entry(i) }
            end
          end
          entries
        end

        def bibliography_entry(item)
          key = val(item, :anchor) || val(item, :id)
          citeas = docid_text(vals(item, :docidentifier).first) ||
            PlainText.call(val(item, :formatted_ref))
          BibliographyEntry.new(
            key: key, citeas: citeas,
            pubid: parse_pubid(citeas),
            item: begin
              ::Relaton::Bib::Item.from_xml(item.to_xml)
            rescue StandardError
              nil
            end
          )
        end

        # A content block's native JSON object: the Mirror node tree —
        # the lossless JSON serialization this gem's JS ecosystem
        # renders from (same handlers the to-mirror CLI uses). This is
        # the blocks' native serialization; the lutaml key-value path
        # cannot serialize content blocks on 0.8.x.
        def mirror_object(block)
          transformer = ::Metanorma::Mirror::Transformer.new
          result = ::Metanorma::Mirror.default_registry.handle(
            block, context: transformer
          )
          Array(result.nodes).each do |node|
            parsed = JSON.parse(
              ::Metanorma::Mirror::Serialization::JsonSerializer
                .serialize(node),
            )
            return parsed if parsed.is_a?(Hash)
          end
          nil
        rescue StandardError
          nil
        end

        # Formula as a native Plurimath::Math::Formula. Plurimath is the
        # Metanorma math ecosystem: parse from the stem's AsciiMath, or
        # from its MathML (the mml model's own XML serialization) when
        # only that is present. Plurimath 0.11 has no data-producing
        # to_json — its native serializations are the to_* forms
        # (asciimath, latex, mathml, omml, unicodemath), which is what
        # consumers get.
        def plurimath_formula(formula_block)
          require "plurimath"
          stem = val(formula_block, :stem)
          return nil unless stem

          expr = val(stem, :asciimath)&.value
          unless expr.to_s.empty?
            return Plurimath::Math.parse(expr.to_s, :asciimath)
          end

          math = val(stem, :math)
          Plurimath::Math.parse(math.to_xml, :mathml) if math
        rescue StandardError, LoadError
          nil
        end

        private

        # -- publisher → pubid flavor --------------------------------

        # "OIML" engages the day the flavor ships (pubid/pubid#342);
        # until then Pubid::Oiml is undefined and parses nil.
        PUBID_FLAVORS = {
          "ISO" => :Iso, "IEC" => :Iec, "ITU" => :Itu, "BSI" => :Bsi,
          "BS" => :Bsi, "OGC" => :Ogc, "NIST" => :Nist, "IEEE" => :Ieee,
          "OIML" => :Oiml
        }.freeze

        def parse_pubid(text)
          return nil if text.nil? || text.empty?

          flavor = PUBID_FLAVORS[text[/\A([A-Za-z]+)/, 1].to_s.upcase]
          return nil unless flavor

          Pubid.const_get(flavor).parse(text)
        rescue StandardError, LoadError, NameError
          nil
        end

        # -- glossarist construction ---------------------------------

        def concept_for(term, lang:, date:)
          g_lang = GLOSSARIST_LANG.fetch(lang, lang)
          designations = vals(term, :preferred)
            .map { |d| PlainText.call(d) }.reject(&:empty?)
          admitted = vals(term, :admitted)
            .map { |d| PlainText.call(d) }.reject(&:empty?)
          deprecated = vals(term, :deprecates)
            .map { |d| PlainText.call(d) }.reject(&:empty?)
          definition = PlainText.call(val(term, :definition))
          sources = vals(term, :source).filter_map do |src|
            citeas = begin
              vals(src, :origin).first&.citeas
            rescue StandardError
              nil
            end
            citeas = PlainText.call(citeas) if citeas
            if citeas && !citeas.empty?
              Glossarist::ConceptSource.new(
                type: "authoritative",
                origin: { "ref" => { "source" => citeas } },
              )
            end
          end
          dates = if date
                    [Glossarist::ConceptDate.new(
                      date: date, type: "accepted",
                    )]
                  else
                    []
                  end
          Glossarist::Concept.new(
            id: anchor_of(term),
            data: Glossarist::ConceptData.new(
              id: "#{anchor_of(term)}-#{g_lang}",
              language_code: g_lang,
              terms: [
                ["preferred", designations],
                ["admitted", admitted],
                ["deprecated", deprecated],
              ].flat_map do |status, terms|
                terms.map do |designation|
                  Glossarist::Designation::Expression.new(
                    designation: designation, normative_status: status,
                  )
                end
              end,
              definition: [Glossarist::DetailedDefinition.new(
                content: definition,
              )],
              sources: sources,
              dates: dates,
              entry_status: "valid",
            ),
          )
        end

        # ISO 639-1 → 639-2/B for Glossarist language codes.
        GLOSSARIST_LANG = {
          "en" => "eng", "fr" => "fre", "de" => "ger", "es" => "spa",
          "ar" => "ara", "ru" => "rus", "zh" => "zho", "ja" => "jpn",
          "ko" => "kor"
        }.freeze

        # -- term-entry traversal (both trees) -----------------------
        #
        # The iso tree declares entries as :term inside terms sections;
        # the standoc tree maps them to :terms. Terms sections are
        # recognizable by the :term declaration.

        def entries(root)
          out = []
          collect_entries(val(root, :sections), out)
          collect_entries(val(root, :preface), out)
          # amendments keep their terms in annexes (e.g. OIML R 60/A1)
          vals(root, :annex).each { |a| collect_entries(a, out) }
          out
        end

        def collect_entries(container, out)
          return unless container

          vals(container, :terms).each do |ts|
            term_entries(ts).each { |t| out << t }
            vals(ts, :terms).each { |nested| collect_terms(nested, out) }
          end
          vals(container, :clause).each { |c| collect_entries(c, out) }
          vals(container, :subsections).each { |c| collect_entries(c, out) }
        end

        def collect_terms(ts, out)
          term_entries(ts).each { |t| out << t }
          vals(ts, :terms).each { |nested| collect_terms(nested, out) }
        end

        def term_entries(ts)
          entries_ = vals(ts, :term)
          entries_ = vals(ts, :terms) if entries_.empty?
          entries_
        end

        def anchor_of(element)
          anchor = val(element, :anchor)
          return anchor if anchor && !anchor.empty?

          id = val(element, :id)
          id && !id.empty? ? id : nil
        end

        def first_lang(root)
          bib = val(root, :bibdata)
          PlainText.call(vals(bib, :language).first).to_s[0, 2]
        end

        def published_on(root)
          bib = val(root, :bibdata)
          vals(bib, :date).filter_map { |d| PlainText.call(val(d, :on)) }
            .first
        end
      end
    end
  end
end
