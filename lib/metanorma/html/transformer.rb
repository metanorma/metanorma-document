# frozen_string_literal: true

module Metanorma
  module Html
    class Transformer
      def initialize(document)
        @document = document
      end

      def transform
        base_json.merge(
          "navigation_index" => IndexGenerator.new(@document).generate,
          "sections_by_id" => build_sections_index,
          "bibitem_by_id" => build_bibitem_index,
        ).then { |h| stringify_keys(h) }
      end

      private

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

      def base_json
        JSON.parse(@document.to_json)
      end

      def build_sections_index
        index = {}
        collect_all_sections.each do |section|
          id = section[:id]
          index[id] = section if id
        end
        index
      end

      def build_bibitem_index
        index = {}
        return index unless @document.bibdata

        # Index bibliographic items from bibliography sections
        Array(@document.bibliography).each do |bib|
          collect_bibitems(bib).each do |item|
            id = item[:id] || item[:doc_identifier]
            index[id] = item if id
          end
        end
        index
      end

      def collect_bibitems(bib_section)
        items = []
        return items unless bib_section.respond_to?(:bibliographic_item)

        Array(bib_section.bibliographic_item).each do |item|
          items << {
            id: item.id,
            doc_identifier: item.doc_identifier&.content,
            title: extract_title(item),
          }
        end
        items
      end

      def collect_all_sections
        sections = []

        # Preface sections
        if @document.preface
          pref = @document.preface
          if pref.respond_to?(:foreword)
            sections << { id: "foreword", title: "Foreword",
                          type: "foreword" }
          end
          if pref.respond_to?(:introduction)
            sections << { id: "introduction", title: "Introduction",
                          type: "introduction" }
          end
          if pref.respond_to?(:abstract)
            sections << { id: "abstract", title: "Abstract",
                          type: "abstract" }
          end
        end

        # Main sections
        if @document.sections
          secs = @document.sections
          if secs.respond_to?(:terms)
            sections << { id: "terms", title: "Terms and Definitions",
                          type: "terms" }
          end
          if secs.respond_to?(:definitions)
            sections << { id: "definitions",
                          title: "Symbols and Abbreviated Terms", type: "definitions" }
          end
          Array(secs.clause).each do |clause|
            collect_clauses(clause, sections)
          end
        end

        # Annexes
        Array(@document.annex).each do |annex|
          sections << {
            id: annex.respond_to?(:id) ? annex.id : nil,
            title: extract_title(annex),
            type: "annex",
            number: annex.respond_to?(:number) ? annex.number : nil,
          }
          collect_subsections(annex, sections)
        end

        # Bibliography
        if @document.bibliography
          sections << { id: "bibliography", title: "Bibliography",
                        type: "bibliography" }
        end

        sections
      end

      def collect_clauses(clause, sections, parent_number = nil)
        number = parent_number ? "#{parent_number}.#{sections.count + 1}" : "1"
        sections << {
          id: clause.respond_to?(:id) ? clause.id : nil,
          title: extract_title(clause),
          type: "clause",
          number: number,
        }
        collect_subsections(clause, sections, number)
      end

      def collect_subsections(section, sections, parent_number = nil)
        return unless section.respond_to?(:clause)

        Array(section.clause).each do |clause|
          collect_clauses(clause, sections, parent_number || "")
        end
      end

      def extract_title(element)
        return nil unless element.respond_to?(:title)

        title = element.title
        return nil unless title

        title.respond_to?(:content) ? title.content : title.to_s
      end
    end
  end
end
