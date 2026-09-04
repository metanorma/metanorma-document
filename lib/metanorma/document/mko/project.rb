# frozen_string_literal: true

module Metanorma
  module Mko
    # The projection: typed document model -> knowledge objects.
    # Dispatches on model classes only (BasicDocument/StandardDocument
    # vocabulary); carries zero flavor knowledge. All attribute access is
    # keyed on lutaml attribute declarations — flavor classes may omit
    # attributes the base trees carry.
    class Project
      include Metanorma::Document::ModelAccess

      class << self
        def call(model, presentation: nil, assets: nil)
          new(model, presentation: presentation, assets: assets).call
        end
      end

      def initialize(model, presentation: nil, assets: nil)
        @model = model
        @presentation = presentation
        @assets = assets
        @units = []
        @units_by_id = {}
        # model element -> unit, by object identity: what re-orders
        # children into document order from element_order
        @element_units = {}
        @edges = []
        @numbers = {}
        @structure = []
        # document order (#56): assigned at emission, never re-derived
        @ordinal = 0
        # units register (#55): entries + symbol lookup for formula refs
        @unitsml = []
        @units_by_symbol = {}
        # The document language resolution (#53 item 3): every unit's
        # lang carries its provenance — markup, heuristic, default, or
        # the explicit fallback (Mko::Language).
        @document_lang = resolve_document_lang(model)
        @lang = @document_lang
        @flavor = flavor_of(model)
        @doc_date = published_on(model)
      end

      # One export = one instance: the walk's state (@units, @edges,
      # @numbers, @structure) is owned by this export, never shared.
      def call
        collect_numbers(@presentation)
        build_units_register(@model)
        walk_root(@model)
        identity = build_identity(@model)
        @edges.concat(document_relation_edges(identity))
        # Native object models (Glossarist concepts, Relaton bibdata)
        # come from the model layer; the projection only serializes.
        Mko::Result.new(document: identity, units: @units, edges: @edges,
                        unitsml: @unitsml,
                        glossary: Document::NativeModels.glossarist_concepts(
                          @model, lang: @lang.lang, date: @doc_date
                        ),
                        bibdata: Document::NativeModels.relaton_bibdata(@model),
                        bibliography:
                     Document::NativeModels.relaton_bibliography(@model),
                        identifiers: build_identifiers(@model),
                        assets: @assets&.entries || [], flavor: @flavor)
      end

      # Cross-document relations from the bibliographic record, as
      # edges: doc:<short> -> ext:<identifier>, kind = the Relaton
      # relation type verbatim (obsoletes, hasSuccessor, hasPart,
      # updates, ...). Relaton's own vocabulary, no lossy mapping —
      # consumers already carry the relaton type tables.
      def document_relation_edges(identity)
        Array(identity.relations).filter_map do |rel|
          to = Document::PlainText.call(rel.to)
          next if to.empty?

          Schema::Edge.new(from: "doc:#{identity.ids.short}",
                           to: "ext:#{to}", kind: rel.type)
        end
      end

      def published_on(model)
        bib = val(model, :bibdata)
        vals(bib, :date).filter_map { |d| scalar(val(d, :on)) }.first
      end

      # Base-quantity attr -> SI vector symbol; the model-side spelling
      # of Mko::Units::BASE_QUANTITY_SYMBOLS (which is keyed by XML
      # element name). Composition itself is shared: vectorize.
      DIMENSION_SYMBOLS = {
        length: "L", mass: "M", time: "T", electric_current: "I",
        thermodynamic_temperature: "Θ", amount_of_substance: "N",
        luminous_intensity: "J", plane_angle: "φ"
      }.freeze
      # Hand-entered status fields contradict their own succession
      # links (#53 item 4: 58 of 224 OIML families); edges are
      # structure. Derived from the Relaton relations verbatim:
      # superseded iff this record names a successor.
      SUCCESSOR_TYPES = %w[hasSuccessor obsoletedBy succeededBy
                           supersededBy updatedBy].freeze
      # Prose containers hold paragraphs and lists (lists are not
      # separate units — their content belongs in the clause text).
      # Composed in document order via element_order, like
      # extract_plain_text, but scoped to prose: tables/figures/
      # formulas are their own units and stay out.
      SECTION_PROSE_SOURCES = {
        "p" => :paragraphs, "ul" => :unordered_lists,
        "ol" => :ordered_lists, "dl" => :definition_lists
      }.freeze
      BLOCK_SOURCES = {
        "table" => :tables, "figure" => :figures, "formula" => :formulas,
        "note" => :notes, "example" => :examples,
        "sourcecode" => :sourcecode_blocks
      }.freeze
      # Element-name -> mapped attributes, for re-ordering a section's
      # child units into document order from element_order (the same
      # interleave trick section_text uses for prose). "clause" and
      # "term" cover both tree spellings (subsections/clause, term/terms).
      SECTION_CHILD_SOURCES = {
        "clause" => %i[subsections clause], "terms" => %i[terms],
        "term" => %i[term terms],
        "table" => %i[tables], "figure" => %i[figures],
        "formula" => %i[formulas], "note" => %i[notes],
        "example" => %i[examples], "sourcecode" => %i[sourcecode_blocks],
        "requirement" => %i[requirement],
        "recommendation" => %i[recommendation],
        "permission" => %i[permission],
        "p" => %i[paragraphs]
      }.freeze

      private

      def flavor_of(model)
        val(model, :flavor) ||
          model.class.name.to_s.split("::")[1]&.downcase
      end

      # Element-level language resolution (#53 item 3): the element's
      # own :lang wins the day the models map xml:lang
      # (metanorma-standoc#1243) — markup stays authoritative; with no
      # xml:lang in scope the element's own prose decides (the stopword
      # langid the RAG consumer shares — a translated annex tags
      # itself); else the enclosing scope, then the document default,
      # stands. Returns the resolution to restore when the scope ends.
      def push_element_lang(element, text: nil)
        previous = @lang
        @lang = Mko::Language.resolve(own: val(element, :lang),
                                      text: text, inherited: previous,
                                      default: @document_lang)
        previous
      end

      # The document-level chain: the root's :lang the day the models
      # map the root xml:lang, else the declared bibdata language, else
      # detection over the document's own prose, else the explicit
      # fallback.
      def resolve_document_lang(model)
        Mko::Language.document(markup: val(model, :lang),
                               declared: first_lang(model),
                               text: document_sample(model))
      end

      def first_lang(model)
        bib = val(model, :bibdata)
        scalar(vals(bib, :language).first)
      end

      # The document-level detection sample: the direct prose of every
      # top-level section (SAMPLE_WORDS caps what detect reads).
      def document_sample(model)
        parts = []
        each_top_section(model) do |s|
          text = section_text(s)
          parts << text unless text.empty?
        end
        parts.join("\n")
      end

      # -- numbering (presentation model) ----------------------------

      def collect_numbers(presentation)
        return unless presentation

        each_top_section(presentation) { |s| number_tree(s, nil) }
      end

      def each_top_section(model, &)
        sections = val(model, :sections)
        walk_container(sections, &)
        preface = val(model, :preface)
        walk_container(preface, &)
        vals(model, :annex).each(&)
      end

      def walk_container(container, &)
        vals(container, :clause).each(&)
        vals(container, :terms).each(&)
        # preface-shaped containers declare :foreword/:introduction
        # sections — OIML-CS admin documents keep their whole body
        # there (semantic XML serializes an empty <sections>)
        vals(container, :foreword).each(&)
        vals(container, :introduction).each(&)
      end

      # Term entries: the iso tree declares them as :term with nested
      # terms-sections in :terms; the standoc tree maps them to :terms.
      def term_entries(tsec)
        entries = vals(tsec, :term)
        entries = vals(tsec, :terms) if entries.empty?
        entries
      end

      def nested_terms_sections(tsec)
        vals(tsec, :term).empty? ? [] : vals(tsec, :terms)
      end

      def number_tree(section, parent)
        register_number(section, parent)
        vals(section, :subsections).each { |s| number_tree(s, section) }
        vals(section, :clause).each { |s| number_tree(s, section) }
        vals(section, :terms).each do |tsec|
          term_entries(tsec).each { |t| register_number(t, tsec) }
          nested_terms_sections(tsec).each { |nested| number_tree(nested, section) }
        end
      end

      def register_number(element, parent)
        anchor = element_anchor(element, parent)
        return unless anchor

        autonum = section_autonum(element)
        @numbers[anchor] = autonum if autonum && !autonum.empty?
      end

      def section_autonum(section)
        autonum = val(section, :autonum)
        return autonum if autonum && !autonum.empty?

        fmt = val(section, :fmt_title)
        fmt ? fmt_autonum(fmt) : nil
      end

      # Clause numbers live in presentation fmt-title spans as semx
      # autonum fragments ("1" + "." + "2" -> "1.2").
      def fmt_autonum(fmt_title)
        parts = []
        collect_semx_autonums(fmt_title, parts)
        parts.empty? ? nil : parts.join(".")
      end

      def collect_semx_autonums(element, out)
        return unless serializable?(element)

        if val(element, :element_attr) == "autonum"
          text = Document::PlainText.call(element)
          out << text unless text.empty?
        end
        element.class.attributes.each_value do |attr|
          next if attr.name.nil?

          raw = element.public_send(attr.name)
          next if raw.nil?

          Array(raw).each do |v|
            collect_semx_autonums(v, out)
          end
        end
      end

      # -- units register (#55) ---------------------------------------

      # The register from the model's typed UnitsML container. The
      # container rides the root-level metanorma-extension (semantic
      # XML puts UnitsML beside presentation-metadata); some trees also
      # nest an extension under bibdata/ext — both are checked. A
      # projection of what the source carries: no re-parsing, no
      # invention.
      def build_units_register(model)
        root = [val(model, :metanorma_extension),
                val(val_any(val(model, :bibdata), :ext, :extension),
                    :metanorma_extension)]
          .filter_map { |mnx| val(mnx, :unitsml) }.first
        return [] unless root

        dimensions = dimension_vectors(root)
        quantity_kinds = dimension_quantity_kinds(root)
        pairs = vals(val(root, :unit_set), :unit).map do |unit|
          [unit, unit_entry(unit, dimensions, quantity_kinds)]
        end
        entries = pairs.map(&:last)
        by_id = entries.to_h { |e| [e.id, e] }
        prefixes = prefix_symbols(root)
        pairs.each do |unit, entry|
          expr = si_expression(unit, by_id, prefixes)
          entry.si_expression = expr if expr
        end
        @units_by_symbol = entries.each_with_object({}) do |e, h|
          h[e.symbol] = e.id if e.symbol
        end
        @unitsml = entries
      end

      def unit_entry(unit, dimensions, quantity_kinds)
        url = val(unit, :dimension_url).to_s.sub("#", "")
        Mko::Units::Entry.new(
          id: val(unit, :id),
          symbol: html_symbol(unit),
          name: scalar(val(unit, :unit_name)),
          quantity_kind: quantity_kinds[url],
          dimension_url: url.empty? ? nil : url,
          dimension: dimensions[url],
        )
      end

      # The display symbol: the HTML-typed UnitSymbol, else the first.
      # Composite symbols carry XML whitespace from pretty-printing —
      # squashed, never significant.
      def html_symbol(unit)
        symbols = vals(unit, :unit_symbol)
        pick = symbols.find { |s| val(s, :type) == "HTML" } || symbols.first
        return nil unless pick

        text = vals(pick, :text).map { |t| scalar(t).to_s.strip }.join(" ")
        text = text.gsub(/\s+/, " ").strip
        text.empty? ? Document::PlainText.call(pick) : text
      end

      def dimension_vectors(root)
        vals(val(root, :dimension_set), :dimension)
          .to_h do |dim|
          [val(dim, :id), Mko::Units.vectorize(
            DIMENSION_SYMBOLS.filter_map do |attr, sym|
              part = val(dim, attr) or next
              [sym, val(part, :power_numerator),
               val(part, :power_denominator)]
            end,
          )]
        end
      end

      # Quantity kinds keyed by dimension URL: a unit's kind is the
      # name of the quantity with the same dimension.
      def dimension_quantity_kinds(root)
        vals(val(root, :quantity_set), :quantity)
          .each_with_object({}) do |q, h|
            url = val(q, :dimension_url).to_s.sub("#", "")
            name = vals(q, :quantity_name).map { |n| scalar(n) }
              .reject(&:empty?).first
            h[url] ||= name if name && !url.empty?
          end
      end

      def prefix_symbols(root)
        vals(val(root, :prefix_set), :prefix)
          .to_h do |p|
          [val(p, :id), vals(p, :prefix_symbol)
            .map { |s| scalar(s) }.join]
        end
      end

      # The unit's composition as the source enumerates it: root-unit
      # symbols with prefixes and powers, resolved within the register.
      def si_expression(unit, by_id, prefixes)
        parts = vals(val(unit, :root_units), :enumerated_root_unit)
          .filter_map do |eru|
            sym = by_id[val(eru, :unit)]&.symbol or next
            sym = "#{prefixes[val(eru, :prefix)]}#{sym}"
            power = val(eru, :power_numerator)
            power && power != 1 ? "#{sym}^#{power}" : sym
          end
        parts.empty? ? nil : parts.join("·")
      end

      # -- identity ----------------------------------------------------

      # Identity comes from the native pubid parser first (one parser,
      # every publisher it covers); the series-letter regex remains as
      # the fallback for publishers pubid does not model. Nil-safe: an unparseable canonical yields nils (fields absent in
      # JSON), never a crash — unknown shapes stay visible, not fatal.
      def parse_identity(canonical)
        native = Document::NativeModels.pubid_identity(canonical)
        return native if native

        m = canonical.to_s.match(/\A(?:[A-Z][A-Za-z0-9&-]*\s+)?([A-Z])\s*(\d+)(?:-(\d+|[A-Za-z][A-Za-z0-9]*))?\b/)
        m ? [m[1], m[2], m[3]] : []
      end

      def build_identity(model)
        bib = val(model, :bibdata)
        ids = docids(bib)
        canonical = ids.find { |d| val(d, :primary) && docid_text(d) }
          &.then { |d| docid_text(d) } ||
          ids.reject { |d| docid_is_urn?(d) }
            .filter_map { |d| docid_text(d) }.first
        series, number, part = parse_identity(canonical)
        Schema::Document.new(
          ids: Schema::Ids.new(
            canonical: canonical,
            short: Mko.slug(canonical),
            series: series,
            number: number,
            part: part,
            docid: ids.filter_map { |d| docid_text(d) },
            urn: ids.select { |d| docid_is_urn?(d) }
              .filter_map { |d| docid_text(d) },
          ),
          flavor: @flavor,
          doctype: doctype_text(bib),
          titles: build_titles(bib),
          edition: scalar(val(bib, :edition)),
          languages: vals(bib, :language).filter_map { |l| scalar(l) },
          status: build_status(bib),
          derived_status: derived_status(build_relations(bib)),
          dates: build_dates(bib),
          relations: build_relations(bib),
          structure: @structure,
        )
      end

      def scalar(value)
        return nil if value.nil?
        return value.map { |v| scalar(v) }.join(" ") if value.is_a?(Array)
        return value.to_s unless serializable?(value)

        Document::PlainText.call(value)
      end

      # Flavors rename some metadata attributes (e.g. the iso tree uses
      # titles/doc_identifier). Prefer the base name; fall back by name.
      def val_any(obj, *names)
        names.each do |n|
          v = val(obj, n)
          return v unless v.nil?
        end
        nil
      end

      # Doctype: base tree is a scalar; iso-style trees nest typed doctype
      # elements under bibdata extensions.
      def doctype_text(bib)
        dt = val_any(bib, :doctype)
        dt = val(val(bib, :ext), :doctype) if dt.nil?
        return nil if dt.nil?

        dt = Array(dt).first if dt.is_a?(Array)
        abbr = val(dt, :abbreviation)
        return abbr.to_s unless abbr.to_s.empty?

        scalar(dt)
      end

      def derived_status(relations)
        has_successor = relations.any? do |r|
          SUCCESSOR_TYPES.include?(r.type) && r.to && !r.to.empty?
        end
        has_successor ? "superseded" : nil
      end

      def build_titles(bib)
        vals_any(bib, :title, :titles).map do |t|
          Schema::TitleEntry.new(lang: val(t, :language)&.to_s,
                                 text: Document::PlainText.call(t))
        end
      end

      def build_status(bib)
        st = val(bib, :status)
        return nil unless st

        stage = Array(val(st, :stage)).first
        Schema::StatusInfo.new(
          stage: stage ? scalar(stage) : nil,
          substage: scalar(val(st, :substage)),
          abbreviation: stage ? val(stage, :abbreviation) : nil,
        )
      end

      def build_dates(bib)
        vals(bib, :date).map do |d|
          Schema::DateEntry.new(type: val(d, :type),
                                on: scalar(val(d, :on)))
        end
      end

      def build_relations(bib)
        vals(bib, :relation).map do |r|
          item = val(r, :bibitem)
          to = docids(item).filter_map { |d| docid_text(d) }.first
          Schema::RelationEntry.new(type: val(r, :type), to: to)
        end
      end

      def build_identifiers(model)
        infos = Document::NativeModels.pubid_identifiers(model).map do |e|
          pubid = e[:pubid] && JSON.parse(e[:pubid].to_json)
          Schema::IdentifierInfo.new(
            original: e[:original], type: e[:type],
            primary: e[:primary], parsed: pubid
          )
        end
        Schema::Identifiers.new(identifiers: infos)
      end

      def vals_any(obj, *names)
        names.filter_map { |n| val(obj, n) }.flat_map { |v| Array(v) }
      end

      def docid_is_urn?(docid)
        val(docid, :type) == "URN" || docid_text(docid).to_s.start_with?("urn:")
      end

      # -- the walk ----------------------------------------------------

      # The iso tree declares Term entries as :term (so a terms
      # section is recognizable by that declaration); the standoc tree
      # maps them to :terms.
      def terms_section?(obj)
        serializable?(obj) && obj.class.attributes.key?(:term)
      end

      def walk_child_section(section, type: "clause")
        if terms_section?(section)
          walk_terms_section(section)
        else
          walk_section(section, type: type)
        end
      end

      def walk_root(model)
        sections = val(model, :sections)
        walk_container(sections) { |s| walk_child_section(s) }
        preface = val(model, :preface)
        walk_container(preface) { |s| walk_child_section(s, type: "clause") }
        vals(model, :annex).each { |a| walk_section(a, type: "annex") }
        walk_bibliography(model)
      end

      # Sections scope the element-level language (#53 item 3): the
      # section's resolution — its own xml:lang the day the models map
      # it, else its own prose, else the enclosing scope — applies to
      # every unit emitted inside.
      def walk_section(section, type: "clause", parent: nil, breadcrumb: [])
        text = section_text(section)
        restore_lang = push_element_lang(section, text: text)
        begin
          anchor = element_anchor(section)
          number = @numbers[anchor] || section_autonum(section)
          title = Document::PlainText.call(val(section, :title))
          unit = emit_unit(
            type: type, anchor: anchor, number: number, title: title,
            parent: parent, breadcrumb: breadcrumb,
            obligation: val(section, :obligation),
            text: text, model: section
          )
          crumb = breadcrumb + [number ? "#{number} #{title}" : title]
          node = Schema::StructureNode.new(id: unit.id, number: number,
                                           title: title)
          @structure << node
          children = walk_blocks(section, unit.id, crumb)
          vals(section, :subsections).each do |sub|
            child = walk_section(sub, parent: unit.id, breadcrumb: crumb)
            node.children << child if child
            children << child if child
          end
          vals(section, :clause).each do |sub|
            child = walk_section(sub, parent: unit.id, breadcrumb: crumb)
            node.children << child if child
            children << child if child
          end
          vals(section, :terms).each do |tsec|
            ts_unit = walk_terms_section(tsec, parent: unit.id,
                                               breadcrumb: crumb)
            children << ts_unit if ts_unit
          end
          finalize_section(unit,
                           ordered_child_ids(section, children.map(&:id)))
          node
        ensure
          @lang = restore_lang
        end
      end

      def walk_terms_section(tsec, parent: nil, breadcrumb: [])
        text = section_text(tsec)
        restore_lang = push_element_lang(tsec, text: text)
        begin
          anchor = element_anchor(tsec)
          number = @numbers[anchor] || section_autonum(tsec)
          title = Document::PlainText.call(val(tsec, :title))
          unit = emit_unit(
            type: "clause", anchor: anchor, number: number, title: title,
            parent: parent, breadcrumb: breadcrumb,
            obligation: val(tsec, :obligation), text: text,
            model: tsec
          )
          crumb = breadcrumb + [title]
          children = term_entries(tsec).map do |t|
            walk_term(t, parent: unit.id, breadcrumb: crumb,
                         section: tsec)
          end
          nested_terms_sections(tsec).each do |nested|
            children << walk_terms_section(nested, parent: unit.id,
                                                   breadcrumb: crumb)
          end
          vals_any(tsec, :paragraphs, :p).each do |p|
            children << emit_unit(type: "note", anchor: element_anchor(p),
                                  parent: unit.id, breadcrumb: crumb,
                                  text: Document::PlainText.call(p), model: p)
          end
          finalize_section(unit, ordered_child_ids(tsec, children.map(&:id)))
          unit
        ensure
          @lang = restore_lang
        end
      end

      def walk_term(term, parent:, breadcrumb:, section: nil)
        anchor = element_anchor(term, section)
        number = @numbers[anchor]
        designations = vals(term, :preferred)
          .map { |d| Document::PlainText.call(d) }.reject(&:empty?)
        # both trees declare the synonym attrs as :admitted/:deprecates
        admitted = vals(term, :admitted)
          .map { |d| Document::PlainText.call(d) }.reject(&:empty?)
        deprecated = vals(term, :deprecates)
          .map { |d| Document::PlainText.call(d) }.reject(&:empty?)
        definition = Document::PlainText.call(val(term, :definition))
        sources = vals(term, :source).map do |src|
          Schema::TermSourceEntry.new(
            citeas: vals(src, :origin).first&.citeas,
          )
        end
        payload = Schema::TermPayload.new(
          concept: anchor, designations: designations,
          admitted: admitted, deprecated: deprecated,
          definition: definition, sources: sources
        )
        unit = emit_unit(
          type: "term", anchor: anchor, number: number,
          title: designations.first, parent: parent,
          breadcrumb: breadcrumb, text: definition, model: term,
          payload: payload
        )
        @edges << Schema::Edge.new(
          from: unit.id, to: "concept:#{anchor}", kind: "defines",
        )
        sources.filter_map(&:citeas).each do |citeas|
          cited = Document::PlainText.call(citeas)
          next if cited.empty?

          @edges << Schema::Edge.new(
            from: unit.id, to: "ext:#{cited}", kind: "cites",
          )
        end
        unit
      end

      def section_text(section)
        collections = SECTION_PROSE_SOURCES.each_with_object({}) do |(_name, attr), h|
          h[attr] = vals(section, attr)
        end
        indices = Hash.new(0)
        parts = []
        # element_order is nil on programmatically built (unparsed)
        # models — the declaration-order fallback below covers them
        Array(section.element_order).each do |el|
          next unless el.is_a?(Lutaml::Xml::Element)

          attr = SECTION_PROSE_SOURCES[el.name.to_s] or next
          item = collections[attr][indices[attr]]
          indices[attr] += 1
          text = Document::PlainText.call(item) if item
          parts << text if text && !text.empty?
        end
        # element_order unavailable: fall back to declaration order
        if parts.empty?
          parts = collections.values.flatten.filter_map do |item|
            text = Document::PlainText.call(item)
            text unless text.empty?
          end
        end
        parts.join("\n")
      end

      def walk_blocks(section, parent_id, breadcrumb)
        BLOCK_SOURCES.flat_map do |type, attr|
          vals(section, attr)
            .map { |block| send("walk_#{type}", block, parent_id, breadcrumb) }
        end + walk_requirements(section, parent_id, breadcrumb)
      end

      def walk_table(table, parent_id, breadcrumb)
        head_row = vals(val(table, :thead), :tr).first
        columns = vals(head_row, :th).map do |cell|
          Schema::TableColumn.new(label: Document::PlainText.call(cell))
        end
        rows = vals(val(table, :tbody), :tr).map do |tr|
          vals(tr, :td).map { |cell| Document::PlainText.call(cell) }.join(" | ")
        end
        payload = Schema::TablePayload.new(
          caption: Document::PlainText.call(val(table, :name)),
          columns: columns, rows: rows,
          mirror: Document::NativeModels.mirror_object(table)
        )
        emit_unit(
          type: "table", anchor: element_anchor(table),
          number: val(table, :autonum),
          title: payload.caption, parent: parent_id,
          breadcrumb: breadcrumb, text: payload.embed_text,
          model: table, payload: payload
        )
      end

      def walk_figure(figure, parent_id, breadcrumb)
        caption = Document::PlainText.call(val(figure, :name))
        img = val(figure, :image)
        uri = val(figure, :source) || val(img, :source) ||
          val(img, :filename)
        alt = val(figure, :alt) || val(img, :alt)
        # retrievability invariant (#53 item 1): an uncaptioned figure
        # still carries retrievable text — its alt text
        retrievable = [caption, alt].compact.reject { |s| s.to_s.empty? }
        payload = Schema::FigurePayload.new(
          alt: alt, uri: uri,
          asset: @assets&.attach(uri),
          caption: caption,
          mirror: Document::NativeModels.mirror_object(figure)
        )
        emit_unit(
          type: "figure", anchor: element_anchor(figure),
          number: val(figure, :autonum), title: caption,
          parent: parent_id, breadcrumb: breadcrumb,
          text: retrievable.join(". "), model: figure, payload: payload
        )
      end

      def walk_formula(formula, parent_id, breadcrumb)
        stem = val(formula, :stem)
        asciimath = val(stem, :asciimath)&.value
        mathml = mathml_of(stem)
        description = Document::PlainText.call(val(formula, :name))
        # Native math object: Plurimath's own serializations (it has no
        # data to_json; to_* are the native forms). Derived encodings
        # are marked with their converter — never canonical (#55).
        plurimath = Document::NativeModels.plurimath_formula(formula)
        payload = Schema::FormulaPayload.new(
          asciimath: asciimath, mathml: mathml,
          units: register_refs(asciimath),
          latex: derived_form(plurimath, :to_latex),
          omml: derived_form(plurimath, :to_omml),
          description: description
        )
        emit_unit(
          type: "formula", anchor: element_anchor(formula),
          number: val(formula, :autonum), title: description,
          parent: parent_id, breadcrumb: breadcrumb,
          text: [asciimath, description].compact.join(" — "),
          model: formula, payload: payload
        )
      end

      def derived_form(plurimath, serializer)
        form = plurimath&.public_send(serializer)
        form && Schema::FormulaPayload::DerivedForm.new(
          form: form, converter: "plurimath",
        )
      end

      # Units a formula uses: the unitsml() tokens of its AsciiMath,
      # resolved against the bundle register by symbol — so consumers
      # compare quantity kinds, never unit strings (#55).
      def register_refs(asciimath)
        asciimath.to_s.scan(/unitsml\(([^)]+)\)/)
          .map(&:first).filter_map { |sym| @units_by_symbol[sym] }
          .uniq
      end

      def mathml_of(stem)
        math = val(stem, :math)
        return nil unless math

        math.to_xml
      rescue StandardError
        nil
      end

      def walk_note(note, parent_id, breadcrumb)
        emit_unit(
          type: "note", anchor: element_anchor(note), parent: parent_id,
          breadcrumb: breadcrumb, text: Document::PlainText.call(note), model: note
        )
      end

      def walk_example(example, parent_id, breadcrumb)
        emit_unit(
          type: "example", anchor: element_anchor(example),
          parent: parent_id, breadcrumb: breadcrumb,
          text: Document::PlainText.call(example), model: example
        )
      end

      def walk_sourcecode(block, parent_id, breadcrumb)
        emit_unit(
          type: "sourcecode", anchor: element_anchor(block),
          number: val(block, :autonum),
          title: Document::PlainText.call(val(block, :name)),
          parent: parent_id, breadcrumb: breadcrumb,
          text: Document::PlainText.call(block), model: block
        )
      end

      def walk_requirements(section, parent_id, breadcrumb)
        %i[requirement recommendation permission].flat_map do |attr|
          vals(section, attr)
            .map { |req| walk_requirement(req, parent_id, breadcrumb) }
        end
      end

      def walk_requirement(req, parent_id, breadcrumb)
        payload = requirement_payload(req)
        unit = emit_unit(
          type: "requirement", anchor: element_anchor(req),
          number: val(req, :autonum), title: payload.identifier,
          parent: parent_id, breadcrumb: breadcrumb,
          obligation: val(req, :obligation), text: payload.statement,
          model: req, payload: payload
        )
        klass = requirement_class(req)
        if klass
          @edges << Schema::Edge.new(
            from: unit.id, to: "class:#{klass}", kind: "class_of",
          )
        end
        vals(req, :requirement).each do |sub|
          walk_requirement(sub, unit.id, breadcrumb)
        end
        unit
      end

      def requirement_payload(req)
        statement = vals(req, :description).map { |d| Document::PlainText.call(d) }
          .reject(&:empty?).join("\n")
        Schema::RequirementPayload.new(
          identifier: val(req, :anchor) || val(req, :id),
          klass: requirement_class(req),
          obligation: val(req, :obligation),
          subject: val(req, :subject), statement: statement,
          inherits: vals(req, :inherit).filter_map do |i|
            text = Array(val(i, :text)).join
            next text unless text.empty?

            val(Array(val(i, :eref)).first, :citeas)
          end
        )
      end

      def requirement_class(req)
        vals(req, :classification).find { |c| val(c, :tag) == "class" }
          .then { |c| c && Document::PlainText.call(val(c, :value)) }
      end

      def walk_bibliography(model)
        bibs = val(model, :bibliography)
        Array(bibs).each { |bib_section| walk_references_section(bib_section) }
      end

      def walk_references_section(bib_section)
        vals(bib_section, :references).each do |refs|
          title = Document::PlainText.call(val(refs, :title))
          section_unit = emit_unit(
            type: "clause", anchor: element_anchor(refs), title: title,
            parent: nil, breadcrumb: [], text: nil, model: refs
          )
          # The base tree maps entries as :bibitem; the standoc/iso
          # tree nests BibliographicItems in :references.
          items = vals(refs, :bibitem)
          items = vals(refs, :references) if items.empty?
          children = items.map do |item|
            key = val(item, :anchor) || val(item, :id)
            cited = docid_text(vals(item, :docidentifier).first) ||
              Document::PlainText.call(val(item, :formatted_ref))
            payload = Schema::ReferencePayload.new(key: key, cited: cited)
            unit = emit_unit(
              type: "reference", anchor: key, title: cited,
              parent: section_unit.id, breadcrumb: [title].compact,
              text: cited, model: item, payload: payload
            )
            if cited && !cited.empty?
              @edges << Schema::Edge.new(
                from: unit.id, to: "ext:#{cited}", kind: "cites",
              )
            end
            unit
          end
          finalize_section(section_unit, children.map(&:id))
        end
      end

      # -- unit assembly -------------------------------------------------

      # Document order, not walk order (#56): children are the ids of
      # this section's direct units, interleaved as the author wrote
      # them. Falls back to emission order when element_order is not
      # available; unmapped stragglers append so no child is lost.
      def ordered_child_ids(section, emitted)
        return emitted if emitted.empty?

        pools = SECTION_CHILD_SOURCES.each_with_object({}) do |(name, attrs), h|
          h[name] = { list: attrs.flat_map { |a| vals(section, a) }, idx: 0 }
        end
        ordered = []
        Array(section.element_order).each do |el|
          next unless el.is_a?(Lutaml::Xml::Element)

          pool = pools[el.name.to_s] or next
          item = pool[:list][pool[:idx]]
          pool[:idx] += 1
          unit = item && @element_units[item]
          ordered << unit.id if unit
        end
        return emitted if ordered.empty?

        ordered + (emitted - ordered)
      end

      # The section contract (#56): coverage payload, retrievable text,
      # and a hash over the finalized content. Runs after the section's
      # children are walked — summaries and membership are only known
      # then.
      def finalize_section(unit, child_ids)
        children = child_ids.filter_map { |id| @units_by_id[id] }
        payload = Schema::SectionPayload.new(
          summary: section_summary(unit, children), children: child_ids,
        )
        # Retrievability invariant: a container section with no direct
        # prose still carries retrievable text — its summary
        unit.text = payload.summary if unit.text.to_s.empty?
        unit.payload = payload_hash(payload)
        unit.hash = content_hash(unit.text, payload)
        unit
      end

      # Deterministic composition — title plus the covered sub-clauses.
      # Never model-inferred: consumers may build their own LLM
      # summaries, but the shipped default requires none.
      def section_summary(unit, children)
        head = [unit.number, unit.title].compact
          .reject { |s| s.to_s.empty? }.join(" ")
        covered = children.filter_map do |c|
          parts = [c.number, c.title].compact.reject { |s| s.to_s.empty? }
          parts.empty? ? nil : parts.join(" ")
        end
        return head if covered.empty?

        [head.empty? ? nil : "#{head}.", "Covers: #{covered.join('; ')}."]
          .compact.join(" ")
      end

      # rubocop:disable-next Metrics/ParameterLists
      def emit_unit(type:, anchor:, parent:, breadcrumb:, text:, model:,
                    payload: nil, number: nil, title: nil, obligation: nil)
        anchor ||= content_anchor(model, type)
        id = "u:#{anchor}"
        cite_as = citation_anchor(anchor: anchor, number: number,
                                  parent: parent)
        unit = Schema::Unit.new(
          id: id, type: type, anchor: anchor, number: number,
          ordinal: @ordinal, cite_as: cite_as, title: title,
          parent: parent, breadcrumb: breadcrumb.compact,
          obligation: obligation, lang: @lang.lang,
          lang_source: @lang.source, text: text,
          payload: payload_hash(payload), hash: content_hash(text, payload)
        )
        @ordinal += 1
        @units << unit
        @units_by_id[id] = unit
        @element_units[model] = unit if model
        if parent
          @edges << Schema::Edge.new(from: id, to: parent, kind: "part_of")
        end
        unit
      end

      # Embedded objects cite their containing clause: a table in §4.1.2
      # is cited as 4.1.2, not as its own anchor. Top-level sections and
      # parentless units cite their own number/anchor.
      def citation_anchor(anchor:, number:, parent:)
        own = number || anchor
        if parent && @units_by_id
          pu = @units_by_id[parent]
          if pu && %w[clause annex].include?(pu.type)
            return (pu.number || pu.anchor || own).to_s
          end
        end
        own&.to_s
      end

      def payload_hash(payload)
        return nil unless payload

        JSON.parse(payload.to_json)
      end

      def content_hash(text, payload)
        basis = text.to_s + payload.to_json
        "sha256:#{Digest::SHA256.hexdigest(basis)[0, 16]}"
      end

      def content_anchor(model, type)
        basis = "#{model.class.name}:#{type}"
        "h-#{Digest::SHA256.hexdigest(basis)[0, 10]}"
      end

      # Semantic anchors (anchor="term-paddy") are the human-meaningful,
      # cross-render-stable identifiers; GUIDs are the last resort. The
      # presentation model repeats the same anchor, so numbering joins
      # survive the preference.
      def element_anchor(element, parent_section = nil)
        anchor = val(element, :anchor)
        return anchor if anchor && !anchor.empty?

        id = val(element, :id)
        return id if id && !id.empty?

        semx = val(element, :semx_id)
        return semx if semx && !semx.empty?

        pid = val(parent_section, :id) || val(parent_section, :anchor)
        pid && "#{pid}-x#{@units.size + 1}"
      end
    end
  end
end
