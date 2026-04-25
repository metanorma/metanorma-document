# frozen_string_literal: true

require "erb"
require "liquid"
require "metanorma/iso_document"

module Metanorma
  module Html
    TEMPLATE_PATH = File.join(__dir__, "template", "document.html.liquid")
    TEMPLATES_ROOT = File.join(__dir__, "template")
    FRONTEND_ROOT = File.expand_path(
      "../../../data/dist/iso_document/frontend", __dir__
    )

    Liquid::Environment.default.file_system = Liquid::LocalFileSystem.new(TEMPLATES_ROOT)

    class Renderer
      MODES = %i[single_file directory].freeze

      attr_reader :document, :mode, :options

      def initialize(document, mode: :single_file, **options)
        @document = document
        @mode = mode
        @options = options
        @model_lookup = {}
      end

      def render
        json_data = build_json_data
        case @mode
        when :single_file
          render_single_file(json_data)
        when :directory
          render_directory(json_data)
        end
      end

      def render_to_file(path)
        content = render
        File.write(path, content)
        path
      end

      private

      # --- Model object lookup ---

      def build_model_lookup!
        collect_models(@document)
      end

      def collect_models(obj)
        return unless obj
        return unless obj.is_a?(Lutaml::Model::Serializable)

        if obj.is_a?(Metanorma::Document::Components::Tables::TableCell)
          # TableCell uses mixed_content — skip to avoid polluting lookup
        elsif obj.respond_to?(:id) && obj.id && !obj.id.to_s.empty?
          @model_lookup[obj.id] = obj
        end

        # Traverse child collections
        traverse_model_children(obj) { |child| collect_models(child) }
      end

      def traverse_model_children(obj)
        # Collections of child blocks
        collection_attrs = [
          :blocks, :p, :clause, :annex, :term, :note, :example, :admonition,
          :table, :figure, :formula, :sourcecode, :quote, :ul, :ol, :dl,
          :references, :bibitem, :termnote, :termexample, :li,
          :callout_annotations, :footnotes, :preferred, :admitted, :deprecates,
          :definition,
        ]
        collection_attrs.each do |attr|
          next unless obj.respond_to?(attr)
          val = obj.public_send(attr)
          next unless val
          Array(val).each { |v| yield v if v.is_a?(Lutaml::Model::Serializable) }
        end

        # Single-value child objects
        single_attrs = [
          :preface, :sections, :bibliography, :boilerplate, :bibdata,
          :foreword, :introduction, :abstract, :key, :stem, :image,
          :thead, :tbody, :tfoot, :body,
        ]
        single_attrs.each do |attr|
          next unless obj.respond_to?(attr)
          val = obj.public_send(attr)
          next unless val
          yield val if val.is_a?(Lutaml::Model::Serializable)
        end

        # Table rows/cells
        if obj.is_a?(Metanorma::Document::Components::Tables::TableSection)
          Array(obj.tr).each do |tr|
            yield tr if tr
            Array(tr.td).each { |td| yield td if td }
            Array(tr.th).each { |th| yield th if th }
          end
        end
      end

      # --- JSON data pipeline ---

      def build_json_data
        build_model_lookup!
        data = base_json
        inject_blocks(data, @document)
        enrich_inline_content(data)
        extract_terms_data(data)
        extract_normative_references_data(data)
        extract_bibliography_data(data)
        extract_boilerplate_data(data)
        collect_footnotes(data)
        toc = IndexGenerator.new(@document).generate
        inject_section_numbers(data, toc)
        data.merge(
          "toc" => stringify_keys(toc),
          "metadata" => stringify_keys(build_metadata),
        )
      end

      def stringify_keys(obj)
        case obj
        when Hash
          obj.each_with_object({}) do |(k, v), acc|
            acc[k.is_a?(Symbol) ? k.to_s : k] = stringify_keys(v)
          end
        when Array
          obj.map { |v| stringify_keys(v) }
        else
          obj
        end
      end

      # Walk JSON tree and replace plain-text content with structured inline arrays
      # using model objects.
      def enrich_inline_content(data)
        return unless data.is_a?(Hash)

        # Enrich blocks in "blocks" arrays
        enrich_block_inline(data["blocks"]) if data["blocks"].is_a?(Array)

        # Enrich blocks in typed collections
        %w[paragraphs unordered_lists ordered_lists tables figures formulas
           examples notes admonitions sourcecode_blocks quote_blocks definition_lists].each do |key|
          enrich_block_inline(data[key]) if data[key].is_a?(Array)
        end

        data.each_value do |v|
          case v
          when Hash
            enrich_inline_content(v)
          when Array
            v.each { |item| enrich_inline_content(item) if item.is_a?(Hash) }
          end
        end
      end

      def enrich_block_inline(blocks)
        blocks.each do |block|
          next unless block.is_a?(Hash) && block["id"]

          model = @model_lookup[block["id"]]
          next unless model

          case block["type"]
          when "paragraph"
            inline = serialize_model_inline(model)
            block["content"] = inline unless inline.empty?
          when "ul", "ol"
            enrich_list_items(block, model)
          when "table"
            if model.is_a?(Metanorma::Document::Components::Tables::TableBlock)
              block["number"] = model.autonum || model.anchor if model.autonum || model.anchor
              build_table_from_model(block, model)
            end
          when "formula"
            if model.is_a?(Metanorma::Document::Components::AncillaryBlocks::FormulaBlock)
              extract_formula_stem(block, model)
              block["number"] = model.autonum || model.anchor if model.autonum || model.anchor
              extract_formula_key_from_model(block, model)
            end
          when "figure"
            if model.is_a?(Metanorma::Document::Components::AncillaryBlocks::FigureBlock)
              enrich_figure_block(block, model)
            end
          when "note", "example"
            enrich_note_or_example(block, model)
          when "admonition"
            enrich_admonition_block(block, model)
          when "sourcecode"
            if model.is_a?(Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock)
              enrich_sourcecode_block(block, model)
            end
          when "quote"
            enrich_quote_block(block, model)
          when "dl"
            enrich_definition_list(block, model)
          end
        end
      end

      # --- List enrichment ---

      def enrich_list_items(block_data, model)
        items = block_data["listitem"]
        return unless items.is_a?(Array)

        li_models = extract_list_items(model)
        items.each_with_index do |item, i|
          next unless item.is_a?(Hash)
          next unless li_models[i]

          li = li_models[i]
          if li.respond_to?(:each_mixed_content)
            inline = serialize_model_inline(li)
            item["content"] = inline unless inline.empty?
          end
        end
      end

      def extract_list_items(model)
        if model.is_a?(Metanorma::Document::Components::Lists::UnorderedList) ||
           model.is_a?(Metanorma::Document::Components::Lists::OrderedList)
          Array(model.li)
        else
          []
        end
      end

      # --- Table building from model ---

      def build_table_from_model(block_data, table)
        # Name/caption
        name_text = extract_name_text(table.name)
        block_data["name"] = name_text if name_text

        # Head rows
        head_rows = []
        if table.thead
          Array(table.thead.tr).each do |tr|
            cells = Array(tr.th).map { |th| serialize_table_cell(th) }
            cells += Array(tr.td).map { |td| serialize_table_cell(td) } if Array(tr.td).any?
            head_rows << { "td" => cells } unless cells.empty?
          end
        end
        block_data["head"] = head_rows unless head_rows.empty?

        # Body rows
        body_rows = []
        if table.tbody
          Array(table.tbody.tr).each do |tr|
            cells = Array(tr.td).map { |td| serialize_table_cell(td) }
            cells += Array(tr.th).map { |th| serialize_table_cell(th) } if Array(tr.th).any?
            body_rows << { "td" => cells } unless cells.empty?
          end
        end
        block_data["body"] = body_rows unless body_rows.empty?

        # Foot rows
        foot_rows = []
        if table.tfoot
          Array(table.tfoot.tr).each do |tr|
            cells = Array(tr.td).map { |td| serialize_table_cell(td) }
            cells += Array(tr.th).map { |th| serialize_table_cell(th) } if Array(tr.th).any?
            foot_rows << { "td" => cells } unless cells.empty?
          end
        end
        block_data["foot"] = foot_rows unless foot_rows.empty?

        # Table notes
        notes = []
        Array(table.note).each do |note_model|
          notes << {
            "id" => note_model.id,
            "content" => serialize_model_inline(note_model),
          }
        end
        block_data["notes"] = notes unless notes.empty?

        # Table footnotes (fn elements inside table cells)
        table_footnotes = []
        seen_refs = Set.new
        collect_table_footnotes(table, seen_refs, table_footnotes)
        block_data["footnotes"] = table_footnotes unless table_footnotes.empty?
      end

      def serialize_table_cell(cell)
        data = {
          "content" => serialize_model_inline(cell),
        }
        data["colspan"] = cell.colspan.to_i if cell.colspan
        data["rowspan"] = cell.rowspan.to_i if cell.rowspan
        data["align"] = cell.align if cell.align
        data["id"] = cell.id if cell.id
        data
      end

      def collect_table_footnotes(table, seen_refs, footnotes)
        # Collect fn elements from table cells
        [:thead, :tbody, :tfoot].each do |section|
          section_obj = table.public_send(section)
          next unless section_obj
          Array(section_obj.tr).each do |tr|
            [:td, :th].each do |cell_type|
              Array(tr.public_send(cell_type)).each do |cell|
                Array(cell.fn).each do |fn|
                  next unless fn.reference
                  next if seen_refs.include?(fn.reference)

                  seen_refs << fn.reference
                  footnotes << {
                    "reference" => fn.reference,
                    "id" => fn.id,
                    "content" => serialize_fn_content(fn),
                  }
                end
              end
            end
          end
        end
      end

      # --- Formula enrichment ---

      def extract_formula_stem(block_data, formula)
        stem = formula.stem
        return unless stem

        if stem.math
          math_items = Array(stem.math)
          if math_items.first.is_a?(Metanorma::Document::Components::Inline::MathElement)
            block_data["mathml"] = math_items.map { |m| m.content.to_s }.join
          end
        end
      end

      def extract_formula_key_from_model(block_data, formula)
        key = formula.key
        return unless key

        dl = key.dl
        return unless dl

        items = extract_dl_items(dl)
        if items.any?
          label = "key"
          # Check if there's a "where" paragraph preceding
          if formula.p && formula.p.any?
            where_text = Array(formula.p).last
            if where_text && extract_text_from_model(where_text).strip.downcase.start_with?("where")
              label = "where"
            end
          end

          block_data["key"] = {
            "label" => label,
            "items" => items,
          }
        end
      end

      # --- Figure enrichment ---

      def enrich_figure_block(block_data, figure)
        if figure.image
          img = figure.image
          block_data["image"] = {
            "src" => img.src,
            "alt" => img.alt,
            "id" => img.id,
          }
        end
        name_text = extract_name_text(figure.name)
        block_data["name"] = name_text if name_text
        block_data["number"] = figure.autonum || figure.anchor if figure.autonum || figure.anchor

        # Key/legend
        if figure.key
          dl = figure.key.dl
          if dl
            items = extract_dl_items(dl)
            if items.any?
              block_data["key"] = { "label" => "key", "items" => items }
            end
          end
        end
      end

      # --- Note/Example enrichment ---

      def enrich_note_or_example(block_data, model)
        paras = Array(model.p)
        if paras.any?
          block_data["content"] = if paras.length == 1
                                    serialize_model_inline(paras.first)
                                  else
                                    paras.map { |p| serialize_model_inline(p) }
                                  end
        end

        # Check for sourcecode inside example
        if model.respond_to?(:sourcecode)
          sourcecodes = Array(model.sourcecode)
          if sourcecodes.first
            sc = sourcecodes.first
            sc_data = {
              "type" => "sourcecode",
              "content" => sc.body ? sc.body.content.to_s : (sc.content || "").to_s,
              "language" => sc.lang,
            }
            name_text = extract_name_text(sc.name)
            sc_data["name"] = name_text if name_text

            # Callout annotations
            annotations = Array(sc.callout_annotations).map do |ca|
              {
                "id" => ca.id,
                "anchor" => ca.anchor,
                "content" => ca.p&.any? ? ca.p.map { |p| serialize_model_inline(p) } : [],
              }
            end
            sc_data["annotations"] = annotations unless annotations.empty?
            block_data["sourcecode"] = sc_data
          end
        end

        name_text = extract_name_text(model.name) if model.respond_to?(:name)
        block_data["name"] = name_text if name_text
      end

      # --- Admonition enrichment ---

      def enrich_admonition_block(block_data, model)
        block_data["admonition_type"] = model.type_attr if model.respond_to?(:type_attr) && model.type_attr
        paras = Array(model.p)
        if paras.any?
          block_data["content"] = if paras.length == 1
                                    serialize_model_inline(paras.first)
                                  else
                                    paras.map { |p| serialize_model_inline(p) }
                                  end
        end
      end

      # --- Sourcecode enrichment ---

      def enrich_sourcecode_block(block_data, model)
        if model.body
          block_data["html_content"] = model.body.content.to_s
          block_data["content"] = model.body.content.to_s
        elsif model.content
          block_data["content"] = model.content
        end
        block_data["language"] = model.lang if model.lang
      end

      # --- Quote enrichment ---

      def enrich_quote_block(block_data, model)
        paras = Array(model.p)
        if paras.any?
          block_data["content"] = paras.map { |p| serialize_model_inline(p) }
        end
        if model.respond_to?(:attribution) && model.attribution
          attr_obj = model.attribution
          if attr_obj.is_a?(Metanorma::Document::Components::Inline::AttributionElement)
            attr_p = Array(attr_obj.p).first
            inline = attr_p ? serialize_model_inline(attr_p) : serialize_model_inline(attr_obj)
            block_data["attribution"] = inline.any? ? inline : extract_text_from_model(attr_obj)
          end
        end
      end

      # --- Definition list enrichment ---

      def enrich_definition_list(block_data, model)
        items = block_data["listitem"]
        return unless items.is_a?(Array)

        # Get dt/dd pairs from the definition list model
        if model.is_a?(Metanorma::Document::Components::Lists::DefinitionList)
          dt_models = Array(model.dt)
          dd_models = Array(model.dd)
          items.each_with_index do |item, i|
            next unless item.is_a?(Hash)

            dt = dt_models[i]
            dd = dd_models[i]
            item["term"] = dt ? serialize_model_inline(dt) : []
            if dd
              dd_paras = Array(dd.p)
              item["definition"] = if dd_paras.any?
                                     dd_paras.map { |p| serialize_model_inline(p) }
                                   else
                                     serialize_model_inline(dd)
                                   end
            end
          end
        end
      end

      # --- Collect footnotes from model ---

      def collect_footnotes(data)
        footnotes = []
        seen_refs = Set.new
        collect_fn_from_model(@document, footnotes, seen_refs)
        data["footnotes"] = footnotes unless footnotes.empty?
      end

      def collect_fn_from_model(obj, footnotes, seen_refs)
        return unless obj

        if obj.is_a?(Metanorma::Document::Components::Inline::FnElement)
          if obj.reference && !seen_refs.include?(obj.reference)
            seen_refs << obj.reference
            footnotes << {
              "reference" => obj.reference,
              "id" => obj.id,
              "content" => serialize_fn_content(obj),
            }
          end
          return
        end

        return unless obj.is_a?(Lutaml::Model::Serializable)

        # Check fn attributes
        if obj.respond_to?(:fn)
          Array(obj.fn).each do |fn|
            if fn.reference && !seen_refs.include?(fn.reference)
              seen_refs << fn.reference
              footnotes << {
                "reference" => fn.reference,
                "id" => fn.id,
                "content" => serialize_fn_content(fn),
              }
            end
          end
        end

        traverse_model_children(obj) { |child| collect_fn_from_model(child, footnotes, seen_refs) }
      end

      def serialize_fn_content(fn)
        paras = Array(fn.p)
        if paras.any?
          paras.length == 1 ? serialize_model_inline(paras.first) : paras.map { |p| serialize_model_inline(p) }
        else
          []
        end
      end

      # --- Model-based inline content serialization ---

      # Serialize a model object's mixed content as a structured inline array.
      # Produces data for Vue to render — NOT HTML.
      def serialize_model_inline(model_obj)
        return [] unless model_obj

        if model_obj.is_a?(String)
          text = model_obj
          return [] if text.strip.empty? && text.length < 2
          return [{ "type" => "text", "value" => text }]
        end

        if model_obj.respond_to?(:each_mixed_content)
          result = []
          model_obj.each_mixed_content do |item|
            if item.is_a?(String)
              text = item
              next if text.strip.empty? && text.length < 2
              result << { "type" => "text", "value" => text }
            else
              serialized = serialize_model_element(item)
              if serialized.is_a?(Array)
                result.concat(serialized)
              elsif serialized
                result << serialized
              end
            end
          end
          return result
        end

        # Fallback: try text attribute
        text = extract_text_from_model(model_obj)
        text && !text.to_s.strip.empty? ? [{ "type" => "text", "value" => text.to_s }] : []
      end

      def serialize_model_element(el)
        case el
        when Metanorma::Document::Components::Inline::EmRawElement
          { "type" => "emphasis", "children" => serialize_model_inline(el) }
        when Metanorma::Document::Components::Inline::StrongRawElement
          { "type" => "strong", "children" => serialize_model_inline(el) }
        when Metanorma::Document::Components::Inline::TtElement
          { "type" => "monospace", "children" => serialize_model_inline(el) }
        when Metanorma::Document::Components::Inline::SubElement
          { "type" => "subscript", "children" => serialize_model_inline(el) }
        when Metanorma::Document::Components::Inline::SupElement
          { "type" => "superscript", "children" => serialize_model_inline(el) }
        when Metanorma::Document::Components::Inline::XrefElement
          { "type" => "cross-ref", "target" => el.target }
        when Metanorma::Document::Components::Inline::ErefElement
          { "type" => "eref", "citeas" => el.citeas, "bibitemid" => el.bibitemid }
        when Metanorma::Document::Components::Inline::LinkElement
          target = el.target || ""
          children = serialize_model_inline(el)
          children = [{ "type" => "text", "value" => target }] if children.empty?
          { "type" => "link", "target" => target, "children" => children }
        when Metanorma::Document::Components::Inline::StemInlineElement
          if el.math && !Array(el.math).empty?
            math_el = Array(el.math).first
            { "type" => "math", "mathml" => math_el.content.to_s }
          else
            { "type" => "stem", "children" => serialize_model_inline(el) }
          end
        when Metanorma::Document::Components::Inline::FnElement
          { "type" => "footnote-ref", "reference" => el.reference }
        when Metanorma::Document::Components::IdElements::Image
          { "type" => "image", "src" => el.src, "alt" => el.alt, "id" => el.id }
        when Metanorma::Document::Components::Inline::SmallCapElement
          { "type" => "smallcap", "children" => [{ "type" => "text", "value" => el.text.to_s }] }
        when Metanorma::Document::Components::Inline::ConceptElement
          if el.renderterm && !Array(el.renderterm).empty?
            { "type" => "concept", "value" => Array(el.renderterm).first.to_s }
          else
            { "type" => "concept", "children" => serialize_model_inline(el) }
          end
        when Metanorma::Document::Components::Inline::BrElement
          { "type" => "line-break" }
        when Metanorma::Document::Components::Inline::TabElement
          { "type" => "text", "value" => "\t" }
        when Metanorma::Document::Components::Inline::SpanElement
          cls = el.class_attr
          if cls
            { "type" => "span", "class" => cls, "children" => serialize_model_inline(el) }
          else
            text = extract_text_from_model(el)
            { "type" => "text", "value" => text }
          end
        when Metanorma::Document::Components::Inline::SemxElement
          # Semx is a presentation wrapper — serialize its children
          serialize_model_inline(el)
        when Metanorma::Document::Components::Inline::FmtXrefElement,
             Metanorma::Document::Components::Inline::FmtFnLabelElement,
             Metanorma::Document::Components::Inline::FmtStemElement,
             Metanorma::Document::Components::Inline::FmtConceptElement,
             Metanorma::Document::Components::Inline::FmtNameElement,
             Metanorma::Document::Components::Inline::FmtXrefLabelElement,
             Metanorma::Document::Components::Inline::FmtTitleElement,
             Metanorma::Document::Components::Inline::FmtFnBodyElement,
             Metanorma::Document::Components::Inline::FmtPreferredElement,
             Metanorma::Document::Components::Inline::FmtDefinitionElement,
             Metanorma::Document::Components::Inline::FmtTermsourceElement,
             Metanorma::Document::Components::Inline::FmtAdmittedElement,
             Metanorma::Document::Components::Inline::FmtIdentifierElement,
             Metanorma::Document::Components::Inline::FmtSourcecodeElement,
             Metanorma::Document::Components::Inline::FmtFootnoteContainerElement,
             Metanorma::Document::Components::Inline::FmtAnnotationBodyElement,
             Metanorma::Document::Components::Inline::FmtAnnotationEndElement,
             Metanorma::Document::Components::Inline::FmtAnnotationStartElement,
             Metanorma::Document::Components::Inline::FmtLinkElement
          # Presentation formatting elements — serialize their inline content
          serialize_model_inline(el)
        when Metanorma::Document::Components::Inline::SemxChildElement
          text = extract_text_from_model(el)
          text && !text.to_s.strip.empty? ? { "type" => "text", "value" => text.to_s } : nil
        when Metanorma::Document::Components::Inline::LocalizedStringElement,
             Metanorma::Document::Components::Inline::LocalizedStringsElement
          text = extract_text_from_model(el)
          text && !text.to_s.strip.empty? ? { "type" => "text", "value" => text.to_s } : nil
        when Metanorma::Document::Components::Inline::VariantTitleElement
          text = extract_text_from_model(el)
          text && !text.to_s.strip.empty? ? { "type" => "text", "value" => text.to_s } : nil
        when Metanorma::Document::Components::Inline::BiblioTagElement
          text = extract_text_from_model(el)
          text && !text.to_s.strip.empty? ? { "type" => "text", "value" => text.to_s } : nil
        else
          # Generic fallback: extract text content
          text = extract_text_from_model(el)
          text && !text.to_s.strip.empty? ? { "type" => "text", "value" => text.to_s } : nil
        end
      end

      # --- Definition list helpers ---

      def extract_dl_items(dl)
        items = []
        dt_models = Array(dl.dt)
        dd_models = Array(dl.dd)
        dt_models.each_with_index do |dt, i|
          dd = dd_models[i]
          items << {
            "term" => serialize_model_inline(dt),
            "definition" => dd ? serialize_model_inline(dd) : [],
          }
        end
        items
      end

      # --- Inject section numbers from TOC ---

      def inject_section_numbers(data, toc)
        return unless toc.is_a?(Hash)

        children = toc[:children] || toc["children"] || []
        number_map = {}
        build_number_map(children, number_map)

        inject_numbers_into_sections(data, number_map)
      end

      def build_number_map(toc_children, map)
        toc_children.each do |entry|
          id = entry[:id] || entry["id"]
          number = entry[:number] || entry["number"]
          map[id] = number if id && number
          sub = entry[:children] || entry["children"] || []
          build_number_map(sub, map) if sub.any?
        end
      end

      def inject_numbers_into_sections(data, number_map)
        return unless data.is_a?(Hash)

        id = data["id"]
        if id && number_map.key?(id)
          data["number"] = number_map[id]
        end

        data.each_value do |v|
          case v
          when Hash
            inject_numbers_into_sections(v, number_map)
          when Array
            v.each do |item|
              if item.is_a?(Hash)
                inject_numbers_into_sections(item, number_map)
              end
            end
          end
        end
      end

      # --- Terms data extraction (model-based) ---

      def extract_terms_data(data)
        return unless data.dig("sections", "terms")

        terms_section = find_terms_section
        return unless terms_section

        terms = []
        Array(terms_section.term).each_with_index do |term, idx|
          term_data = {
            "id" => term.id,
            "anchor" => term.anchor,
            "number" => (idx + 1).to_s,
          }

          # Preferred designation
          preferred = extract_term_preferred(term)
          term_data["preferred"] = preferred || ""

          # Admitted
          admitted = extract_term_designations(term, :admitted)
          term_data["admitted"] = admitted if admitted.any?

          # Deprecated
          deprecated = extract_term_designations(term, :deprecates)
          term_data["deprecated"] = deprecated if deprecated.any?

          # Definition
          defn = extract_term_definition(term)
          term_data["definition"] = defn if defn

          # Notes
          notes = extract_term_notes(term)
          term_data["notes"] = notes if notes.any?

          # Examples
          examples = extract_term_examples(term)
          term_data["examples"] = examples if examples.any?

          # Source
          source_data = extract_term_source(term)
          term_data["source"] = source_data if source_data

          # Domain
          if term.domain
            domain_text = term.domain.is_a?(String) ? term.domain : extract_text_from_model(term.domain)
            term_data["domain"] = domain_text if domain_text && !domain_text.to_s.strip.empty?
          end

          terms << term_data
        end

        data["sections"]["terms"]["term_entries"] = terms
      end

      def find_terms_section
        secs = @document.sections
        return nil unless secs

        if secs.respond_to?(:terms)
          terms = secs.terms
          return terms if terms
        end

        nil
      end

      def extract_term_preferred(term)
        preferreds = Array(term.preferred)
        return nil unless preferreds.first

        pref = preferreds.first
        extract_designation_name(pref)
      end

      def extract_term_designations(term, attr)
        designations = attr == :deprecates ? Array(term.deprecates) : Array(term.public_send(attr))
        designations.filter_map { |d| extract_designation_name(d) }
      end

      def extract_designation_name(designation)
        if designation.respond_to?(:expression) && designation.expression
          expr = designation.expression
          if expr.respond_to?(:name)
            name = expr.name
            return name.is_a?(String) ? name : extract_text_from_model(name)
          end
        end
        extract_text_from_model(designation)
      end

      def extract_term_definition(term)
        defs = Array(term.definition)
        return nil unless defs.first

        defn = defs.first
        if defn.respond_to?(:verbal_definition) && defn.verbal_definition
          vd = defn.verbal_definition
          paras = Array(vd.p)
          if paras.first
            return serialize_model_inline(paras.first)
          end
        end

        if defn.respond_to?(:p) && defn.p && !Array(defn.p).empty?
          return serialize_model_inline(Array(defn.p).first)
        end

        nil
      end

      def extract_term_notes(term)
        notes = []
        if term.respond_to?(:termnote)
          Array(term.termnote).each do |n|
            paras = Array(n.p)
            notes << (paras.any? ? serialize_model_inline(paras.first) : extract_text_from_model(n))
          end
        end
        notes
      end

      def extract_term_examples(term)
        examples = []
        if term.respond_to?(:termexample)
          Array(term.termexample).each do |e|
            paras = Array(e.p)
            examples << (paras.any? ? serialize_model_inline(paras.first) : extract_text_from_model(e))
          end
        end
        examples
      end

      def extract_term_source(term)
        sources = []
        if term.respond_to?(:source)
          sources = Array(term.source)
        elsif term.respond_to?(:termsource)
          sources = Array(term.termsource)
        end
        return nil unless sources.first

        src = sources.first
        source_data = {}

        if src.respond_to?(:origin) && src.origin
          origin = Array(src.origin).first
          if origin
            citeas = origin.respond_to?(:citeas) ? origin.citeas : nil
            source_data["citeas"] = citeas if citeas
          end
        end

        if src.respond_to?(:status) && src.status
          source_data["status"] = src.status
        end

        # Modification
        if src.respond_to?(:modification) && src.modification
          mod = src.modification
          if mod.respond_to?(:p) && Array(mod.p).any?
            source_data["modification"] = extract_text_from_model(Array(mod.p).first)
          else
            source_data["modification"] = extract_text_from_model(mod)
          end
        end

        # Look up bibitem by docidentifier
        if source_data["citeas"]
          bibitem = find_bibitem_by_citeas(source_data["citeas"])
          if bibitem
            source_data["bibitem_id"] = bibitem["id"] if bibitem["id"]
            source_data["bibitem_anchor"] = bibitem["anchor"] if bibitem["anchor"]
          end
        end

        source_data.empty? ? nil : source_data
      end

      # --- Normative references (model-based) ---

      def extract_normative_references_data(data)
        data["normative_references"] = nil

        bibs = @document.respond_to?(:bibliography) ? Array(@document.bibliography) : []
        bibs.each do |bib|
          refs = bib.respond_to?(:references) ? Array(bib.references) : []
          norm_ref = refs.find { |r| r.normative == "true" }
          next unless norm_ref

          title = extract_name_text(norm_ref.title) || "Normative references"

          intro_blocks = []
          Array(norm_ref.p).each do |p|
            intro_blocks << {
              "type" => "paragraph",
              "id" => p.id,
              "content" => serialize_model_inline(p),
            }
          end

          references = []
          Array(norm_ref.references).each do |bibitem|
            ref_data = extract_bibitem_from_model(bibitem)
            references << ref_data
          end

          data["normative_references"] = {
            "id" => norm_ref.id,
            "title" => title,
            "normative" => "true",
            "blocks" => intro_blocks,
            "references" => references,
          }
          break
        end
      end

      # --- Bibliography (model-based) ---

      def extract_bibliography_data(data)
        bibs = @document.respond_to?(:bibliography) ? Array(@document.bibliography) : []
        return if bibs.empty?

        bib_sections = []
        bibs.each do |bib|
          refs = bib.respond_to?(:references) ? Array(bib.references) : []
          refs.each do |ref_node|
            next if ref_node.normative == "true"

            title = extract_name_text(ref_node.title) || "Bibliography"

            intro_blocks = []
            Array(ref_node.p).each do |p|
              intro_blocks << {
                "type" => "paragraph",
                "id" => p.id,
                "content" => serialize_model_inline(p),
              }
            end

            references = []
            Array(ref_node.references).each do |bibitem|
              ref_data = extract_bibitem_from_model(bibitem)
              references << ref_data
            end

            bib_sections << {
              "id" => ref_node.id,
              "title" => title,
              "normative" => ref_node.normative,
              "blocks" => intro_blocks,
              "references" => references,
            }
          end
        end

        data["bibliography"] = bib_sections unless bib_sections.empty?
      end

      # --- Bibitem extraction (model-based) ---

      def extract_bibitem_from_model(bibitem)
        ref_data = {
          "id" => bibitem.id,
          "anchor" => bibitem.anchor,
        }

        # Docidentifier
        docids = Array(bibitem.docidentifier) if bibitem.respond_to?(:docidentifier)
        if docids && !docids.empty?
          primary = docids.find { |di| di.respond_to?(:primary) && di.primary == "true" }
          primary ||= docids.find { |di| di.respond_to?(:type_attr) && di.type_attr == "ISO" }
          primary ||= docids.first
          if primary
            id_val = extract_text_from_model(primary)
            ref_data["docidentifier"] = id_val
            ref_data["docidentifier_type"] = primary.type_attr if primary.respond_to?(:type_attr)
          end
        end

        # Title
        titles = Array(bibitem.title) if bibitem.respond_to?(:title)
        if titles && !titles.empty?
          main_title = titles.find { |t| t.respond_to?(:type_attr) && t.type_attr == "main" }
          main_title ||= titles.first
          title_text = extract_text_from_model(main_title)
          ref_data["title"] = title_text.to_s.strip
        end

        # Contributors
        contributors = []
        Array(bibitem.contributor).each do |contrib|
          role = contrib.role
          org = contrib.organization if contrib.respond_to?(:organization)
          next unless role && org

          role_desc = extract_role_description(role)
          org_name = extract_org_name(org)
          if role_desc && org_name
            contributors << { "role" => role_desc, "organization" => org_name }
          end
        end
        ref_data["contributors"] = contributors if contributors.any?

        # Date
        dates = Array(bibitem.date) if bibitem.respond_to?(:date)
        if dates && !dates.empty?
          date = dates.first
          date_on = date.on if date.respond_to?(:on)
          date_val = extract_text_from_model(date_on)
          ref_data["date"] = date_val if date_val && !date_val.to_s.strip.empty?
        end

        # Formatted reference
        if bibitem.respond_to?(:formattedref) && bibitem.formattedref
          formatted = bibitem.formattedref
          ref_data["formatted_ref"] = serialize_model_inline(formatted)
        end

        # Construct formatted_ref if missing
        if ref_data["formatted_ref"].nil? || ref_data["formatted_ref"].empty?
          parts = []
          parts << ref_data["docidentifier"] if ref_data["docidentifier"]
          parts << ref_data["title"] if ref_data["title"]
          parts << ref_data["date"] if ref_data["date"]
          ref_data["formatted_ref"] = parts.join(". ").strip unless parts.empty?
        end

        ref_data
      end

      def extract_role_description(role)
        return nil unless role
        descriptions = Array(role.description) if role.respond_to?(:description)
        return nil unless descriptions
        desc = descriptions.first
        desc.is_a?(String) ? desc : extract_text_from_model(desc)
      end

      def extract_org_name(org)
        return nil unless org
        names = Array(org.name) if org.respond_to?(:name)
        return nil unless names && !names.empty?
        name = names.first
        name.is_a?(String) ? name : extract_text_from_model(name)
      end

      def find_bibitem_by_citeas(citeas)
        bibs = @document.respond_to?(:bibliography) ? Array(@document.bibliography) : []
        bibs.each do |bib|
          refs = bib.respond_to?(:references) ? Array(bib.references) : []
          refs.each do |ref_node|
            Array(ref_node.references).each do |bibitem|
              docids = Array(bibitem.docidentifier) if bibitem.respond_to?(:docidentifier)
              next unless docids
              docids.each do |di|
                return extract_bibitem_from_model(bibitem) if extract_text_from_model(di) == citeas
              end
            end
          end
        end
        nil
      end

      # --- Boilerplate (model-based) ---

      def extract_boilerplate_data(data)
        boilerplate = @document.boilerplate
        return unless boilerplate

        blocks = []
        extract_boilerplate_blocks(boilerplate, blocks)

        data["boilerplate"] = { "blocks" => blocks } unless blocks.empty?
      end

      def extract_boilerplate_blocks(boilerplate, blocks)
        # Look for copyright-statement or clauses with paragraphs
        if boilerplate.respond_to?(:clause)
          Array(boilerplate.clause).each do |clause|
            Array(clause.p).each do |p|
              blocks << {
                "type" => "paragraph",
                "id" => p.id,
                "anchor" => p.anchor,
                "content" => serialize_model_inline(p),
              }
            end
          end
        end

        # Direct paragraphs on boilerplate
        if boilerplate.respond_to?(:p)
          Array(boilerplate.p).each do |p|
            blocks << {
              "type" => "paragraph",
              "id" => p.id,
              "anchor" => p.anchor,
              "content" => serialize_model_inline(p),
            }
          end
        end
      end

      # --- Block injection (same structure, model-based) ---

      def inject_blocks(data, node)
        return unless node && data.is_a?(Hash)

        # Sections and block containers have blocks + mixed content
        if node.is_a?(Lutaml::Model::Serializable) && node.respond_to?(:blocks) && node.respond_to?(:each_mixed_content)
          data["blocks"] = serialize_blocks(node.blocks)
        end

        if node.respond_to?(:preface) && node.preface && data["preface"]
          inject_blocks(data["preface"], node.preface)
        end

        if node.respond_to?(:foreword) && node.foreword && data["foreword"]
          inject_blocks(data["foreword"], node.foreword)
        end

        if node.respond_to?(:introduction) && node.introduction && data["introduction"]
          inject_blocks(data["introduction"], node.introduction)
        end

        if node.respond_to?(:sections) && node.sections && data["sections"]
          inject_blocks(data["sections"], node.sections)
        end

        %i[terms definitions].each do |attr|
          next unless node.respond_to?(attr)

          val = node.public_send(attr)
          next unless val && data[attr.to_s]

          inject_blocks(data[attr.to_s], val)
        end

        %i[clause annex appendix].each do |attr|
          next unless node.respond_to?(attr)

          collection = node.public_send(attr)
          next unless collection

          json_arr = data[attr.to_s]
          next unless json_arr.is_a?(Array)

          Array(collection).each_with_index do |item, i|
            inject_blocks(json_arr[i], item) if json_arr[i]
          end
        end
      end

      SECTION_TYPES = [
        Metanorma::IsoDocument::Sections::IsoClauseSection,
        Metanorma::IsoDocument::Sections::IsoAnnexSection,
      ].freeze

      def serialize_blocks(blocks)
        return [] unless blocks

        blocks.filter_map do |block|
          next if SECTION_TYPES.any? { |t| block.is_a?(t) }

          json = JSON.parse(block.to_json)
          content = json["content"]
          next if content.is_a?(String) && content.strip.empty?

          json
        rescue StandardError
          next
        end
      end

      def base_json
        JSON.parse(@document.to_json)
      end

      # --- Metadata (model-based) ---

      def build_metadata
        return {} unless @document.bibdata

        bib = @document.bibdata
        {
          "title" => extract_title,
          "docidentifier" => extract_docidentifier(bib),
          "full_title" => extract_full_title(bib),
          "edition" => extract_edition(bib),
          "date" => extract_date(bib),
          "committee" => extract_committee(bib),
          "secretariat" => extract_secretariat(bib),
          "ics" => extract_ics_from_model(bib),
          "stage" => extract_stage(bib),
          "stagename" => extract_stagename(bib),
          "doctype" => extract_doctype(bib),
        }.compact
      end

      def extract_docidentifier(bib)
        docids = Array(bib.doc_identifier) if bib.respond_to?(:doc_identifier)
        docids ||= Array(bib.docidentifier) if bib.respond_to?(:docidentifier)
        return nil unless docids && !docids.empty?

        primary = docids.find { |di| di.respond_to?(:primary) && di.primary == "true" }
        primary ||= docids.find { |di| di.respond_to?(:type_attr) && di.type_attr == "ISO" }
        primary ||= docids.first

        primary ? extract_text_from_model(primary) : nil
      end

      def extract_full_title(bib)
        titles = bib.respond_to?(:titles) ? bib.titles : nil
        return nil unless titles

        intro_title = find_title_by_type(bib, "title-intro")
        main_title = find_title_by_type(bib, "title-main")
        part_title = find_title_by_type(bib, "title-part")

        parts = [intro_title, main_title, part_title].compact.reject(&:empty?)
        full = parts.join(" \u2014 ")
        full.empty? ? nil : full
      end

      def find_title_by_type(bib, type)
        titles = bib.respond_to?(:titles) ? bib.titles : nil
        return nil unless titles

        title = titles.find { |t| t.respond_to?(:type_attr) && t.type_attr == type }
        title ? extract_text_from_model(title) : nil
      end

      def extract_edition(bib)
        return nil unless bib.respond_to?(:edition)
        edition = bib.edition
        edition.is_a?(String) ? edition.strip : extract_text_from_model(edition)
      end

      def extract_date(bib)
        dates = bib.date
        return nil unless dates

        date = Array(dates).find { |d| d.type == "published" }
        date ||= Array(dates).first
        return nil unless date

        date_on = date.respond_to?(:on) ? date.on : nil
        date_val = extract_text_from_model(date_on)
        date_val && !date_val.to_s.strip.empty? ? date_val.to_s.strip : nil
      end

      def extract_committee(bib)
        Array(bib.contributor).each do |c|
          next unless c.role

          roles = Array(c.role)
          next unless roles.any? do |r|
            Array(r.description).any? do |d|
              d.is_a?(Lutaml::Model::Serializable) ? d.value == "committee" : d.to_s == "committee"
            end
          end

          org = c.organization
          next unless org

          subdivisions = Array(org.subdivision)
          parts = []
          subdivisions.each do |s|
            next unless s.respond_to?(:identifier) && s.identifier
            identifiers = Array(s.identifier)
            type = s.respond_to?(:type) ? s.type : nil
            if type == "Technical committee" || type == "Subcommittee"
              id = identifiers.first
              parts << id if id
            end
          end
          return parts.join("/") unless parts.empty?
        end
        nil
      end

      def extract_secretariat(bib)
        Array(bib.contributor).each do |c|
          next unless c.role

          roles = Array(c.role)
          next unless roles.any? do |r|
            Array(r.description).any? do |d|
              d.is_a?(Lutaml::Model::Serializable) ? d.value == "secretariat" : d.to_s == "secretariat"
            end
          end

          org = c.organization
          next unless org

          subdivisions = Array(org.subdivision)
          sec = subdivisions.find { |s| s.respond_to?(:type) && s.type == "Secretariat" }
          if sec && sec.respond_to?(:name)
            name = sec.name
            return name.is_a?(String) ? name : extract_text_from_model(name)
          end
        end
        nil
      end

      def extract_ics_from_model(bib)
        extract_ics(bib)
      end

      def extract_ics(bib)
        ext = bib.ext
        return nil unless ext

        ics_list = Array(ext.ics)
        return nil if ics_list.empty?

        code = ics_list.first.code
        code&.split&.first
      end

      def extract_stage(bib)
        status = bib.status
        return nil unless status

        stages = Array(status.stage)
        stage_obj = stages.first
        return nil unless stage_obj

        stage_obj.value || stage_obj.abbreviation
      end

      def extract_stagename(bib)
        ext = bib.ext
        ext&.stage_name
      end

      def extract_doctype(bib)
        ext = bib.ext
        return nil unless ext

        doctype = ext.doctype
        return nil unless doctype && !doctype.empty?

        first = doctype.is_a?(Array) ? doctype.first : doctype
        first.is_a?(String) ? first : first.value
      end

      # --- Text extraction helpers ---

      def extract_text_from_model(obj)
        return "" if obj.nil?
        return obj if obj.is_a?(String)
        return obj.to_s if obj.is_a?(Symbol) || obj.is_a?(Numeric)

        if obj.is_a?(Lutaml::Model::Serializable)
          # Try text attribute first (common for mixed content elements)
          if obj.respond_to?(:text) && obj.text
            texts = Array(obj.text)
            joined = texts.join
            return joined unless joined.strip.empty?
          end

          # Try element_order for text content
          if obj.respond_to?(:element_order) && obj.element_order.is_a?(Array)
            text_parts = obj.element_order
              .select { |e| e.is_a?(Lutaml::Xml::Element) && e.node_type == :text }
              .map(&:text_content)
            return text_parts.join unless text_parts.empty?
          end

          # Try value attribute
          if obj.respond_to?(:value) && obj.value
            return obj.value.to_s
          end

          # Try content attribute
          if obj.respond_to?(:content) && obj.content
            return obj.content.to_s
          end
        end

        ""
      end

      def extract_name_text(name)
        return nil unless name
        if name.is_a?(String)
          return name.empty? ? nil : name
        end
        text = extract_text_from_model(name)
        text && !text.strip.empty? ? text.strip : nil
      end

      # --- Rendering ---

      def render_single_file(json_data)
        template = Liquid::Template.parse(File.read(TEMPLATE_PATH))
        template.render(
          "title" => extract_title,
          "document_json" => json_data.to_json,
          "mode" => @mode.to_s,
          "base_url" => "",
          "assets_inline" => true,
          "app_css" => read_frontend_asset("app.css"),
          "app_js" => read_frontend_asset("app.js"),
        )
      end

      def render_directory(json_data)
        ensure_assets_directory
        write_assets(json_data)
        template = Liquid::Template.parse(File.read(TEMPLATE_PATH))
        template.render(
          "title" => extract_title,
          "document_json" => json_data.to_json,
          "mode" => @mode.to_s,
          "base_url" => ".",
          "assets_inline" => false,
        )
      end

      def ensure_assets_directory
        assets_dir = File.join(@options[:output_dir] || ".", "assets")
        FileUtils.mkdir_p(assets_dir)
      end

      def write_assets(json_data)
        output_dir = @options[:output_dir] || "."
        assets_dir = File.join(output_dir, "assets")
        File.write(File.join(assets_dir, "app.css"),
                   read_frontend_asset("app.css"))
        File.write(File.join(assets_dir, "app.js"),
                   read_frontend_asset("app.js"))
        File.write(File.join(assets_dir, "document.json"), json_data.to_json)
      end

      def read_frontend_asset(filename)
        path = File.join(FRONTEND_ROOT, "assets", filename)
        File.read(path)
      rescue Errno::ENOENT
        "// #{filename} not found at #{FRONTEND_ROOT}/assets/"
      end

      def extract_title
        return "ISO Document" unless @document.bibdata

        bib = @document.bibdata
        full_title = extract_full_title(bib)
        return full_title if full_title

        title = bib.title
        return "ISO Document" unless title

        if title.is_a?(Lutaml::Model::Serializable) && title.respond_to?(:title_full) && title.title_full
          val = title.title_full
          val = val.value if val.is_a?(Lutaml::Model::Serializable)
          return val if val && !val.to_s.include?("#<")
        end
        result = title.to_s
        result && !result.to_s.include?("#<") ? result : "ISO Document"
      end
    end
  end
end
