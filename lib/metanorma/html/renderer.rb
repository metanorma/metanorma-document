# frozen_string_literal: true

require "erb"
require "liquid"
require "nokogiri"
require "metanorma/iso_document"

module Metanorma
  module Html
    TEMPLATE_PATH = File.join(__dir__, "template", "document.html.liquid")
    TEMPLATES_ROOT = File.join(__dir__, "template")
    FRONTEND_ROOT = File.expand_path("../../../data/dist/iso_document/frontend", __dir__)

    Liquid::Environment.default.file_system = Liquid::LocalFileSystem.new(TEMPLATES_ROOT)

    class Renderer
      MODES = %i[single_file directory].freeze

      attr_reader :document, :mode, :options

      def initialize(document, mode: :single_file, **options)
        @document = document
        @mode = mode
        @options = options
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

      def nokogiri_doc
        @nokogiri_doc ||= begin
          xml = @xml_string || @document.to_xml
          doc = Nokogiri::XML(xml)
          doc.remove_namespaces!
          doc
        end
      end

      def node_lookup
        @node_lookup ||= begin
          lookup = {}
          nokogiri_doc.traverse do |node|
            if node.element? && node["id"]
              lookup[node["id"]] = node
            end
          end
          lookup
        end
      end

      # --- JSON data pipeline ---

      def build_json_data
        data = base_json
        inject_blocks(data, @document)
        enrich_inline_content(data)
        extract_terms_data(data)
        extract_normative_references_data(data)
        extract_bibliography_data(data)
        extract_boilerplate_data(data)
        collect_footnotes(data)
        toc = IndexGenerator.new(@document,
                                 nokogiri_doc: nokogiri_doc).generate
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

      # Walk JSON tree and replace plain-text content with structured inline arrays.
      # Uses Nokogiri to extract rich inline data (emphasis, cross-refs, links, etc.)
      # that the Lutaml model loses. Produces DATA, not HTML -- Vue renders it.
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

          node = node_lookup[block["id"]]
          next unless node

          case block["type"]
          when "paragraph"
            inline = serialize_inline_content(node)
            block["content"] = inline unless inline.empty?
          when "ul", "ol"
            # Enrich list items -- find matching <ul>/<ol> and serialize each <li>
            enrich_list_items(block, node)
          when "table"
            # In presentation XML, autonum contains pre-computed number (e.g., "1", "D.1")
            if node["autonum"] || node["anchor"]
              block["number"] =
                node["autonum"] || node["anchor"]
            end
            # Rebuild table structure from XML (the model can't parse ISO table HTML)
            rebuild_table(block, node)
          when "formula"
            stem_el = node.at_css("stem")
            if stem_el
              math_el = stem_el.at_xpath(".//math")
              block["mathml"] = math_el.inner_html if math_el
            end
            if node["autonum"] || node["anchor"]
              block["number"] =
                node["autonum"] || node["anchor"]
            end
            # Extract formula key/legend (where ... dl)
            extract_formula_key(block, node)
          when "figure"
            image_el = node.at_css("image")
            if image_el
              block["image"] =
                { "src" => image_el["src"], "alt" => image_el["alt"],
                  "id" => image_el["id"] }
            end
            name_el = node.at_css("> name")
            block["name"] = name_el.text.strip if name_el
            if node["autonum"] || node["anchor"]
              block["number"] =
                node["autonum"] || node["anchor"]
            end
            # Extract figure key/legend
            extract_figure_key(block, node)
          when "note", "example"
            # Notes/examples may contain paragraphs and other blocks
            paras = node.css("> p")
            if paras.any?
              block["content"] = paras.map { |p| serialize_inline_content(p) }
            end
            # Check for sourcecode inside example
            sourcecode = node.at_css("> sourcecode")
            if sourcecode
              block["sourcecode"] = {
                "type" => "sourcecode",
                "content" => sourcecode.at_css("> body")&.text || sourcecode.text,
                "language" => sourcecode["lang"],
              }
              # Extract name
              name_el = sourcecode.at_css("> name")
              block["sourcecode"]["name"] = name_el.text.strip if name_el
              # Extract callout annotations
              annotations = sourcecode.css("> callout-annotation").map do |ca|
                p_el = ca.at_css("> p")
                {
                  "id" => ca["id"],
                  "anchor" => ca["anchor"],
                  "content" => p_el ? serialize_inline_content(p_el) : ca.text.strip,
                }
              end
              unless annotations.empty?
                block["sourcecode"]["annotations"] =
                  annotations
              end
            end
            # Check for name element
            name_el = node.at_css("> name")
            block["name"] = name_el.text.strip if name_el
          when "admonition"
            block["admonition_type"] = node["type"] if node["type"]
            paras = node.css("> p")
            if paras.any?
              block["content"] = if paras.length == 1
                                   serialize_inline_content(paras.first)
                                 else
                                   paras.map do |p|
                                     serialize_inline_content(p)
                                   end
                                 end
            end
          when "sourcecode"
            # Preserve syntax highlighting spans by using inner_html of <pre> or body
            pre_el = node.at_css("> pre")
            body_el = node.at_css("> body")
            source_el = pre_el || body_el
            if source_el
              block["html_content"] = source_el.inner_html
              block["content"] = source_el.text
            else
              block["content"] = node.inner_html
            end
            block["language"] = node["lang"] if node["lang"]
          when "quote"
            paras = node.css("> p")
            if paras.any?
              block["content"] = paras.map { |p| serialize_inline_content(p) }
            end
            attribution = node.at_css("attribution")
            if attribution
              attribution_p = attribution.at_css("> p")
              attribution_source = attribution_p || attribution
              inline = serialize_inline_content(attribution_source)
              block["attribution"] = inline.any? ? inline : attribution.text
            end
          when "dl"
            # Enrich definition list items
            items = block["listitem"]
            if items.is_a?(Array)
              dt_nodes = node.css("> dt").to_a
              dd_nodes = node.css("> dd").to_a
              items.each_with_index do |item, i|
                next unless item.is_a?(Hash)

                dt = dt_nodes[i]
                dd = dd_nodes[i]
                item["term"] = dt ? serialize_inline_content(dt) : []
                if dd
                  paras = dd.css("> p")
                  item["definition"] = if paras.any?
                                         paras.map do |p|
                                           serialize_inline_content(p)
                                         end
                                       else
                                         serialize_inline_content(dd)
                                       end
                end
              end
            end
          end
        end
      end

      def enrich_list_items(block_data, xml_node)
        items = block_data["listitem"]
        return unless items.is_a?(Array)

        li_nodes = xml_node.css("> li").to_a
        items.each_with_index do |item, i|
          next unless item.is_a?(Hash)

          li = li_nodes[i]
          next unless li

          paras = li.css("> p")
          if paras.any?
            # Flatten single-paragraph items
            item["content"] = if paras.length == 1
                                serialize_inline_content(paras[0])
                              else
                                paras.map { |p| serialize_inline_content(p) }
                              end
          else
            inline = serialize_inline_content(li)
            item["content"] = inline unless inline.empty?
          end
        end
      end

      # Rebuild table data entirely from Nokogiri since the model can't parse ISO tables.
      # Produces structured data: { head: [{td: [{content: [...]}]}], body: [...] }
      def rebuild_table(block_data, xml_node)
        # Caption from <name> element
        name_el = xml_node.at_css("name")
        name_text = name_el&.text&.strip

        # Table number: prefer autonum already set, then derive from anchor
        table_num = block_data["number"] || xml_node["autonum"]
        unless table_num
          anchor = xml_node["anchor"]
          if anchor
            table_num = anchor.sub(/^table([A-Z]?)(.+)$/i) do
              prefix = $1
              num = $2.gsub("-", ".")
              prefix && !prefix.empty? ? "#{prefix}#{num}" : num
            end
          end
        end
        block_data["number"] = table_num if table_num

        # Build display name: "Table N -- caption text"
        if name_text && table_num
          block_data["name"] = name_text
        elsif name_text
          block_data["name"] = name_text
        end

        # Head rows
        head_rows = []
        xml_node.css("thead tr").each do |tr|
          cells = tr.css("th, td").map { |cell| parse_table_cell(cell) }
          head_rows << { "td" => cells } unless cells.empty?
        end
        block_data["head"] = head_rows unless head_rows.empty?

        # Body rows
        body_rows = []
        xml_node.css("tbody tr").each do |tr|
          cells = tr.css("td, th").map { |cell| parse_table_cell(cell) }
          body_rows << { "td" => cells } unless cells.empty?
        end
        block_data["body"] = body_rows unless body_rows.empty?

        # Foot rows
        foot_rows = []
        xml_node.css("tfoot tr").each do |tr|
          cells = tr.css("td, th").map { |cell| parse_table_cell(cell) }
          foot_rows << { "td" => cells } unless cells.empty?
        end
        block_data["foot"] = foot_rows unless foot_rows.empty?

        # Table notes (direct children, not inside tfoot)
        notes = []
        xml_node.css("> note").each do |note_el|
          p_el = note_el.at_css("> p")
          notes << {
            "id" => note_el["id"],
            "content" => serialize_inline_content(p_el || note_el),
          }
        end
        block_data["notes"] = notes unless notes.empty?

        # Table footnotes (fn elements inside table cells)
        table_footnotes = []
        seen_refs = Set.new
        xml_node.css("fn").each do |fn_el|
          next unless fn_el["reference"]

          ref = fn_el["reference"]
          next if seen_refs.include?(ref)

          seen_refs << ref
          p_el = fn_el.at_css("> p")
          table_footnotes << {
            "reference" => ref,
            "id" => fn_el["id"],
            "content" => serialize_inline_content(p_el || fn_el),
          }
        end
        unless table_footnotes.empty?
          block_data["footnotes"] =
            table_footnotes
        end
      end

      def parse_table_cell(cell)
        data = {
          "content" => serialize_inline_content(cell),
        }
        data["colspan"] = cell["colspan"].to_i if cell["colspan"]
        data["rowspan"] = cell["rowspan"].to_i if cell["rowspan"]
        data["align"] = cell["align"] if cell["align"]
        data["id"] = cell["id"] if cell["id"]
        data
      end

      # Extract formula key/legend (where ... dl) that follows a formula block
      # Expected XML structure after formula:
      #   <p>where</p>
      #   <div class="key formula_dl"><dl><dt>...</dt><dd>...</dd></dl></div>
      def extract_formula_key(block_data, formula_node)
        # In presentation XML, the key element is a CHILD of <formula>, not a sibling
        key_el = formula_node.at_css("key")
        key_el ||= formula_node.at_xpath("following-sibling::key[1]")
        unless key_el
          # Another fallback: check for div with class "key"
          key_el = formula_node.at_css("div.key")
          key_el ||= formula_node.at_xpath("following-sibling::div[contains(@class, 'key')][1]")
        end
        return unless key_el

        # Check for "where" label - look for a preceding <p> with "where" inside the formula
        where_p = key_el.at_xpath("preceding-sibling::p[1][contains(text(), 'where')]")
        label = where_p ? "where" : "key"

        # Extract dt/dd pairs from the dl inside the key element
        items = []
        key_el.css("dl > dt").each_with_index do |dt, _idx|
          dd = dt.at_xpath("following-sibling::dd[1]")
          term_content = serialize_inline_content(dt)
          def_content = dd ? serialize_inline_content(dd) : []
          items << {
            "term" => term_content,
            "definition" => def_content,
          }
        end

        if items.any?
          block_data["key"] = {
            "label" => label,
            "items" => items,
          }
        end
      end

      # Extract key/legend from inside a figure
      # Expected XML structure inside figure:
      #   <div class="key formula_dl"><dl><dt>...</dt><dd>...</dd></dl></div>
      def extract_figure_key(block_data, figure_node)
        key_div = figure_node.at_css("key")
        key_div ||= figure_node.at_css("div.key")
        return unless key_div

        items = []
        key_div.css("dl > dt").each_with_index do |dt, _idx|
          dd = dt.at_xpath("following-sibling::dd[1]")
          term_content = serialize_inline_content(dt)
          def_content = dd ? serialize_inline_content(dd) : []
          items << {
            "term" => term_content,
            "definition" => def_content,
          }
        end

        if items.any?
          block_data["key"] = {
            "label" => "key",
            "items" => items,
          }
        end
      end

      # Collect footnote definitions from XML into a top-level footnotes map
      def collect_footnotes(data)
        footnotes = []
        nokogiri_doc.css("fn").each do |fn|
          next unless fn["reference"]

          footnotes << {
            "reference" => fn["reference"],
            "id" => fn["id"],
            "content" => serialize_inline_content(fn),
          }
        end
        data["footnotes"] = footnotes unless footnotes.empty?
      end

      # Inject section numbers from TOC into the data tree by matching IDs
      def inject_section_numbers(data, toc)
        return unless toc.is_a?(Hash)

        children = toc[:children] || toc["children"] || []
        number_map = {}
        build_number_map(children, number_map)

        # Walk data tree and inject numbers
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

        # Inject number on this node if it has an id match
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
                inject_numbers_into_sections(item,
                                             number_map)
              end
            end
          end
        end
      end

      def extract_terms_data(data)
        return unless data.dig("sections", "terms")

        terms_node = nokogiri_doc.at_css("terms")
        return unless terms_node

        terms = []
        terms_node.css("> term").each_with_index do |term_el, idx|
          term_data = {
            "id" => term_el["id"],
            "anchor" => term_el["anchor"],
            "number" => (idx + 1).to_s,
          }

          preferred = term_el.at_css("preferred > expression > name") ||
            term_el.at_css("preferred expression name")
          term_data["preferred"] = preferred&.text || ""

          admitted = term_el.css("admitted > expression > name").map(&:text)
          term_data["admitted"] = admitted if admitted.any?

          deprecated = term_el.css("deprecates > expression > name").map(&:text)
          term_data["deprecated"] = deprecated if deprecated.any?

          def_el = term_el.at_css("definition > verbal-definition > p")
          if def_el
            term_data["definition"] = serialize_inline_content(def_el)
          end

          notes = term_el.xpath("./termnote | ./note").map do |n|
            p_el = n.at_css("> p")
            p_el ? serialize_inline_content(p_el) : n.text.strip
          end
          term_data["notes"] = notes if notes.any?

          examples = term_el.xpath("./termexample | ./example").map do |e|
            p_el = e.at_css("> p")
            p_el ? serialize_inline_content(p_el) : e.text.strip
          end
          term_data["examples"] = examples if examples.any?

          source_el = term_el.at_css("source")
          if source_el
            origin = source_el.at_css("origin")
            citeas = origin&.[]("citeas")
            term_data["source"] = {
              "citeas" => citeas,
              "status" => source_el["status"],
            }
            # Extract modification text when source is modified
            if source_el["status"] == "modified"
              modification_el = source_el.at_css("modification")
              if modification_el
                p_el = modification_el.at_css("> p")
                term_data["source"]["modification"] =
                  p_el ? p_el.text.strip : modification_el.text.strip
              end
            end
            # Look up bibitem by docidentifier to enable linking
            if citeas
              bibitem = find_bibitem_by_docidentifier(citeas)
              term_data["source"]["bibitem_id"] = bibitem["id"] if bibitem
              if bibitem
                term_data["source"]["bibitem_anchor"] =
                  bibitem["anchor"]
              end
            end
          end

          domain_el = term_el.at_css("> domain")
          term_data["domain"] = domain_el.text.strip if domain_el

          terms << term_data
        end

        data["sections"]["terms"]["term_entries"] = terms
      end

      # Extract normative references from <references normative="true"> elements
      # These are typically inside <sections>, not in <bibliography>
      def extract_normative_references_data(data)
        data["normative_references"] = nil

        nokogiri_doc.css("references[normative='true']").each do |ref_node|
          title_el = ref_node.at_css("> title")
          title = title_el&.text
          title = "Normative references" if title.nil? || title.strip.empty?

          intro_blocks = ref_node.css("> p").map do |p_el|
            {
              "type" => "paragraph",
              "id" => p_el["id"],
              "content" => serialize_inline_content(p_el),
            }
          end

          references = []
          ref_node.css("> bibitem").each do |bibitem|
            ref_data = extract_bibitem_data(bibitem)
            references << ref_data
          end

          data["normative_references"] = {
            "id" => ref_node["id"],
            "title" => title,
            "normative" => "true",
            "blocks" => intro_blocks,
            "references" => references,
          }
          break # Only take the first normative references section
        end
      end

      def extract_bibliography_data(data)
        bib_node = nokogiri_doc.at_css("bibliography")
        return unless bib_node

        bib_sections = []
        bib_node.css("> references").each do |ref_node|
          normative = ref_node["normative"]
          next if normative == "true"

          title_el = ref_node.at_css("> title")
          title = title_el&.text
          title = "Bibliography" if title.nil? || title.strip.empty?

          intro_blocks = ref_node.css("> p").map do |p_el|
            {
              "type" => "paragraph",
              "id" => p_el["id"],
              "content" => serialize_inline_content(p_el),
            }
          end

          references = []
          ref_node.css("> bibitem").each do |bibitem|
            ref_data = extract_bibitem_data(bibitem)
            references << ref_data
          end

          bib_sections << {
            "id" => ref_node["id"],
            "title" => title,
            "normative" => normative,
            "blocks" => intro_blocks,
            "references" => references,
          }
        end

        data["bibliography"] = bib_sections unless bib_sections.empty?
      end

      # Extract comprehensive data from a bibitem element
      def extract_bibitem_data(bibitem)
        ref_data = {
          "id" => bibitem["id"],
          "anchor" => bibitem["anchor"],
        }

        # Docidentifier (primary identifier like ISO 5725-1:1994)
        docid = bibitem.at_css("docidentifier[primary='true']")
        docid ||= bibitem.at_css("docidentifier[type='ISO']")
        docid ||= bibitem.at_css("docidentifier")
        ref_data["docidentifier"] = docid&.text || ""
        ref_data["docidentifier_type"] = docid&.[]("type") if docid

        # Title - try different title types
        title_el = bibitem.at_css("title[type='main']")
        title_el ||= bibitem.at_css("title")
        ref_data["title"] = title_el&.text&.strip || ""

        # Contributor/Author - extract from contributor elements
        contributors = []
        bibitem.css("contributor").each do |contrib|
          role_el = contrib.at_css("role")
          org_el = contrib.at_css("organization > name")
          if role_el && org_el
            contributors << {
              "role" => role_el.at_css("description")&.text,
              "organization" => org_el.text,
            }
          end
        end
        ref_data["contributors"] = contributors if contributors.any?

        # Date
        date_el = bibitem.at_css("date")
        if date_el
          ref_data["date"] =
            date_el.at_css("on")&.text || date_el.at_css("from")&.text
        end

        # Publisher/Author - another common location
        bibitem.css("publisher > name").each do |pub_name|
          ref_data["publisher"] ||= pub_name.text
        end

        # URL/URI
        uri_el = bibitem.at_css("uri")
        ref_data["uri"] = uri_el&.text if uri_el

        # Place of publication
        place_el = bibitem.at_css("place")
        ref_data["place"] = place_el&.text if place_el

        # Edition
        edition_el = bibitem.at_css("edition")
        ref_data["edition"] = edition_el&.text if edition_el

        # Formatted reference (rich inline content)
        formatted_ref = bibitem.at_css("formattedref")
        if formatted_ref
          ref_data["formatted_ref"] = serialize_inline_content(formatted_ref)
        end

        # If we have a formatted_ref, use it as the display text in the UI
        # Otherwise, construct from available parts
        if ref_data["formatted_ref"].nil? || ref_data["formatted_ref"].empty?
          parts = []
          parts << ref_data["docidentifier"] if ref_data["docidentifier"]
          parts << ref_data["title"] if ref_data["title"]
          parts << ref_data["date"] if ref_data["date"]
          unless parts.empty?
            ref_data["formatted_ref"] =
              parts.join(". ").strip
          end
        end

        ref_data
      end

      # Find a bibitem by its docidentifier (for linking term sources to bibliography)
      def find_bibitem_by_docidentifier(docidentifier)
        return nil unless docidentifier

        nokogiri_doc.css("bibitem").each do |bibitem|
          docid = bibitem.at_css("docidentifier[primary='true']")
          docid ||= bibitem.at_css("docidentifier[type='ISO']")
          docid ||= bibitem.at_css("docidentifier")
          return extract_bibitem_data(bibitem) if docid&.text == docidentifier
        end
        nil
      end

      # Extract boilerplate/copyright data from XML into structured format
      def extract_boilerplate_data(data)
        boilerplate = nokogiri_doc.at_css("boilerplate")
        return unless boilerplate

        clause = boilerplate.at_css("clause[anchor^='boilerplate-copyright']")
        clause ||= boilerplate.at_css("clause[id^='boilerplate-copyright']")
        clause ||= boilerplate.at_css("clause")
        return unless clause

        blocks = clause.css("> p").map do |p_el|
          {
            "type" => "paragraph",
            "id" => p_el["id"],
            "anchor" => p_el["anchor"],
            "content" => serialize_inline_content(p_el),
          }
        end

        data["boilerplate"] = { "blocks" => blocks } unless blocks.empty?
      end

      # Serialize Nokogiri XML node children as structured inline content array.
      # This is NOT HTML rendering -- it produces a data structure that Vue renders.
      def serialize_inline_content(node)
        return [] unless node

        node.children.filter_map do |child|
          case child
          when Nokogiri::XML::Text
            text = child.text
            next if text.strip.empty? && text.length < 2

            { "type" => "text", "value" => text }
          when Nokogiri::XML::Element
            serialize_inline_element(child)
          end
        end
      end

      def serialize_inline_element(el)
        children = serialize_inline_content(el)

        case el.name
        when "em"
          { "type" => "emphasis", "children" => children }
        when "strong"
          { "type" => "strong", "children" => children }
        when "tt"
          { "type" => "monospace", "children" => children }
        when "sub"
          { "type" => "subscript", "children" => children }
        when "sup"
          { "type" => "superscript", "children" => children }
        when "xref"
          { "type" => "cross-ref", "target" => el["target"],
            "children" => children }
        when "eref"
          { "type" => "eref", "citeas" => el["citeas"],
            "bibitemid" => el["bibitemid"] }
        when "link"
          target = el["target"] || ""
          text_children = if children.any?
                            children
                          else
                            [{ "type" => "text",
                               "value" => target }]
                          end
          { "type" => "link", "target" => target,
            "children" => text_children }
        when "stem"
          math_el = el.at_xpath(".//math")
          if math_el
            { "type" => "math", "mathml" => math_el.inner_html }
          else
            { "type" => "stem", "children" => children }
          end
        when "fn"
          { "type" => "footnote-ref", "reference" => el["reference"] }
        when "image"
          { "type" => "image", "src" => el["src"], "alt" => el["alt"],
            "id" => el["id"] }
        when "smallcap"
          { "type" => "smallcap", "children" => children }
        when "keyword"
          { "type" => "keyword", "children" => children }
        when "strike"
          { "type" => "strike", "children" => children }
        when "underline"
          { "type" => "underline", "children" => children }
        when "concept"
          renderterm = el.at_css("renderterm")
          if renderterm
            { "type" => "concept", "value" => renderterm.text }
          else
            { "type" => "concept", "children" => children }
          end
        when "br"
          { "type" => "line-break" }
        when "span"
          cls = el["class"]
          if cls
            { "type" => "span", "class" => cls, "children" => children }
          else
            { "type" => "text", "value" => el.text }
          end
        when "name"
          { "type" => "text", "value" => el.text }
        else
          children.any? ? children : { "type" => "text", "value" => el.text }
        end
      end

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

      def build_metadata
        return {} unless @document.bibdata

        bib = @document.bibdata
        {
          "title" => extract_title,
          "docidentifier" => extract_docidentifier,
          "full_title" => extract_full_title,
          "edition" => extract_edition,
          "date" => extract_date_from_xml,
          "committee" => extract_committee_from_xml,
          "secretariat" => extract_secretariat_from_xml,
          "ics" => extract_ics_from_model(bib),
          "stage" => extract_stage(bib),
          "stagename" => extract_stagename(bib),
          "doctype" => extract_doctype(bib),
        }.compact
      end

      def extract_edition
        edition = nokogiri_doc.at_css("bibdata > edition")
        edition&.text&.strip
      end

      def extract_date_from_xml
        version = nokogiri_doc.at_css("bibdata > version")
        version&.text&.strip
      end

      def extract_committee_from_xml
        # Find contributor with role=committee, extract TC/SC/WG identifiers
        committee_contrib = nokogiri_doc.css("bibdata > contributor").find do |c|
          c.at_css("> role")&.text&.strip == "committee"
        end
        return nil unless committee_contrib

        parts = []
        committee_contrib.css("organization > subdivision").each do |sub|
          id = sub.at_css("> identifier")&.text&.strip
          parts << id if id && !id.empty?
        end
        parts.empty? ? nil : parts.join("/")
      end

      def extract_secretariat_from_xml
        secretariat_contrib = nokogiri_doc.css("bibdata > contributor").find do |c|
          c.at_css("> role")&.text&.strip == "secretariat"
        end
        return nil unless secretariat_contrib

        subdiv = secretariat_contrib.css("organization > subdivision").find do |s|
          s["type"] == "Secretariat"
        end
        subdiv&.at_css("> name")&.text&.strip
      end

      def extract_ics_from_xml
        ics_code = nokogiri_doc.at_css("bibdata > ics > code")&.text&.strip
        ics_code&.split&.first # "67.060" from "67.060"
      end

      def extract_docidentifier
        docid = nokogiri_doc.at_css("bibdata > docidentifier[primary='true']")
        return docid.text if docid

        docid = nokogiri_doc.at_css("bibdata > docidentifier[type='ISO']")
        return docid.text if docid

        docid = nokogiri_doc.at_css("bibdata > docidentifier")
        docid&.text
      end

      def extract_full_title
        intro = nokogiri_doc.at_css("bibdata > title[type='title-intro']")&.text
        main = nokogiri_doc.at_css("bibdata > title[type='title-main']")&.text
        part = nokogiri_doc.at_css("bibdata > title[type='title-part']")&.text
        parts = [intro, main, part].compact.reject(&:empty?)
        full = parts.join(" \u2014 ")
        full.empty? ? nil : full
      end

      def extract_date(bib)
        dates = bib.date
        return nil unless dates

        date = Array(dates).find { |d| d.type == "published" }
        date ||= Array(dates).first
        return nil unless date

        date.on || date.from
      end

      def extract_committee(bib)
        Array(bib.contributor).each do |c|
          next unless c.role

          roles = Array(c.role)
          next unless roles.any? do |r|
            Array(r.description).any? do |d|
              d.is_a?(Lutaml::Model::Serializable) ? d.value == "committee" : d == "committee"
            end
          end

          org = c.organization
          next unless org

          subdivisions = Array(org.subdivision)
          tc = subdivisions.find { |s| s.type == "Technical committee" }
          sc = subdivisions.find { |s| s.type == "Subcommittee" }
          parts = []
          if tc
            identifier = Array(tc.identifier).first
            parts << identifier if identifier
          end
          if sc
            identifier = Array(sc.identifier).first
            parts << identifier if identifier
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
              d.is_a?(Lutaml::Model::Serializable) ? d.value == "secretariat" : d == "secretariat"
            end
          end

          org = c.organization
          next unless org

          subdivisions = Array(org.subdivision)
          sec = subdivisions.find { |s| s.type == "Secretariat" }
          return sec.name if sec&.name
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

        ics_list.first.code
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

        full_title = extract_full_title
        return full_title if full_title

        bib = @document.bibdata
        title = bib.title
        return "ISO Document" unless title

        if title.is_a?(Lutaml::Model::Serializable) && title.title_full
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
