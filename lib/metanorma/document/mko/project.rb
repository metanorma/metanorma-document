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
        @edges = []
        @numbers = {}
        @structure = []
        @lang = first_lang(model)
        @flavor = flavor_of(model)
        @doc_date = published_on(model)
      end

      # One export = one instance: the walk's state (@units, @edges,
      # @numbers, @structure) is owned by this export, never shared.
      def call
        collect_numbers(@presentation)
        walk_root(@model)
        identity = build_identity(@model)
        @edges.concat(document_relation_edges(identity))
        # Native object models (Glossarist concepts, Relaton bibdata)
        # come from the model layer; the projection only serializes.
        Mko::Result.new(document: identity, units: @units, edges: @edges,
                   glossary: Document::NativeModels.glossarist_concepts(
                     @model, lang: @lang, date: @doc_date
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

      private

      def flavor_of(model)
        val(model, :flavor) ||
          model.class.name.to_s.split("::")[1]&.downcase
      end

      def first_lang(model)
        bib = val(model, :bibdata)
        scalar(vals(bib, :language).first)
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
      def term_entries(ts)
        entries = vals(ts, :term)
        entries = vals(ts, :terms) if entries.empty?
        entries
      end

      def nested_terms_sections(ts)
        vals(ts, :term).empty? ? [] : vals(ts, :terms)
      end

      def number_tree(section, parent)
        register_number(section, parent)
        vals(section, :subsections).each { |s| number_tree(s, section) }
        vals(section, :clause).each { |s| number_tree(s, section) }
        vals(section, :terms).each do |ts|
          term_entries(ts).each { |t| register_number(t, ts) }
          nested_terms_sections(ts).each { |nested| number_tree(nested, section) }
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

      # Hand-entered status fields contradict their own succession
      # links (#53 item 4: 58 of 224 OIML families); edges are
      # structure. Derived from the Relaton relations verbatim:
      # superseded iff this record names a successor.
      SUCCESSOR_TYPES = %w[hasSuccessor obsoletedBy succeededBy
                           supersededBy updatedBy].freeze

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

      def docid_is_urn?(d)
        val(d, :type) == "URN" || docid_text(d).to_s.start_with?("urn:")
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

      def walk_section(section, type: "clause", parent: nil, breadcrumb: [])
        anchor = element_anchor(section)
        number = @numbers[anchor] || section_autonum(section)
        title = Document::PlainText.call(val(section, :title))
        unit = emit_unit(
          type: type, anchor: anchor, number: number, title: title,
          parent: parent, breadcrumb: breadcrumb,
          obligation: val(section, :obligation),
          text: section_text(section), model: section
        )
        crumb = breadcrumb + [number ? "#{number} #{title}" : title]
        node = Schema::StructureNode.new(id: unit.id, number: number,
                                         title: title)
        @structure << node
        walk_blocks(section, unit.id, crumb)
        vals(section, :subsections).each do |sub|
          child = walk_section(sub, parent: unit.id, breadcrumb: crumb)
          node.children << child if child
        end
        vals(section, :clause).each do |sub|
          child = walk_section(sub, parent: unit.id, breadcrumb: crumb)
          node.children << child if child
        end
        vals(section, :terms).each do |ts|
          walk_terms_section(ts, parent: unit.id, breadcrumb: crumb)
        end
        node
      end

      def walk_terms_section(ts, parent: nil, breadcrumb: [])
        anchor = element_anchor(ts)
        number = @numbers[anchor] || section_autonum(ts)
        title = Document::PlainText.call(val(ts, :title))
        unit = emit_unit(
          type: "clause", anchor: anchor, number: number, title: title,
          parent: parent, breadcrumb: breadcrumb,
          obligation: val(ts, :obligation), text: section_text(ts),
          model: ts
        )
        crumb = breadcrumb + [title]
        term_entries(ts).each do |t|
          walk_term(t, parent: unit.id, breadcrumb: crumb, section: ts)
        end
        nested_terms_sections(ts).each do |nested|
          walk_terms_section(nested, parent: unit.id, breadcrumb: crumb)
        end
        vals_any(ts, :paragraphs, :p).each do |p|
          emit_unit(type: "note", anchor: element_anchor(p),
                    parent: unit.id, breadcrumb: crumb,
                    text: Document::PlainText.call(p), model: p)
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
      end

      # Prose containers hold paragraphs and lists (lists are not
      # separate units — their content belongs in the clause text).
      # Composed in document order via element_order, like
      # extract_plain_text, but scoped to prose: tables/figures/
      # formulas are their own units and stay out.
      SECTION_PROSE_SOURCES = {
        "p" => :paragraphs, "ul" => :unordered_lists,
        "ol" => :ordered_lists, "dl" => :definition_lists
      }.freeze

      def section_text(section)
        collections = SECTION_PROSE_SOURCES.each_with_object({}) do |(_name, attr), h|
          h[attr] = vals(section, attr)
        end
        indices = Hash.new(0)
        parts = []
        section.element_order.each do |el|
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

      BLOCK_SOURCES = {
        "table" => :tables, "figure" => :figures, "formula" => :formulas,
        "note" => :notes, "example" => :examples,
        "sourcecode" => :sourcecode_blocks
      }.freeze

      def walk_blocks(section, parent_id, breadcrumb)
        BLOCK_SOURCES.each do |type, attr|
          vals(section, attr).each do |block|
            send("walk_#{type}", block, parent_id, breadcrumb)
          end
        end
        walk_requirements(section, parent_id, breadcrumb)
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
        # data to_json; to_* are the native forms).
        plurimath = Document::NativeModels.plurimath_formula(formula)
        payload = Schema::FormulaPayload.new(
          asciimath: asciimath, mathml: mathml,
          latex: plurimath&.to_latex, omml: plurimath&.to_omml,
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
        %i[requirement recommendation permission].each do |attr|
          vals(section, attr).each do |req|
            walk_requirement(req, parent_id, breadcrumb)
          end
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
          items.each do |item|
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
          end
        end
      end

      # -- unit assembly -------------------------------------------------

      def emit_unit(type:, anchor:, parent:, breadcrumb:, text:, model:,
                    payload: nil, number: nil, title: nil, obligation: nil)
        anchor ||= content_anchor(model, type)
        id = "u:#{anchor}"
        cite_as = citation_anchor(anchor: anchor, number: number,
                                  parent: parent, type: type)
        unit = Schema::Unit.new(
          id: id, type: type, anchor: anchor, number: number,
          cite_as: cite_as, title: title,
          parent: parent, breadcrumb: breadcrumb.compact,
          obligation: obligation, lang: @lang, text: text,
          payload: payload_hash(payload), hash: content_hash(text, payload)
        )
        @units << unit
        @units_by_id[id] = unit
        if parent
          @edges << Schema::Edge.new(from: id, to: parent, kind: "part_of")
        end
        unit
      end

      # Embedded objects cite their containing clause: a table in §4.1.2
      # is cited as 4.1.2, not as its own anchor. Top-level sections and
      # parentless units cite their own number/anchor.
      def citation_anchor(anchor:, number:, parent:, type:)
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
