# frozen_string_literal: true

require "nokogiri"
require "metanorma/iso_document"

module Metanorma
  module Html
    class IndexGenerator
      def initialize(document, nokogiri_doc: nil)
        @document = document
        @nokogiri_doc = nokogiri_doc
      end

      def generate
        {
          type: "standard-document",
          children: build_children,
        }
      end

      private

      def build_children
        children = []

        # Preface (foreword, introduction)
        children.concat(build_preface_children)

        # Numbered body sections in document order:
        # 1 Scope, 2 Normative references, 3 Terms, 4+ Clauses
        children.concat(build_body_children)

        # Annexes (lettered A, B, C, ...)
        children.concat(build_annex_children)

        # Bibliography (informative)
        children.concat(build_bibliography_children)

        children
      end

      def build_preface_children
        pref = @document.preface
        return [] unless pref

        children = []

        if pref.foreword
          children << {
            id: pref.foreword.id || "foreword",
            title: extract_title(pref.foreword) || "Foreword",
            type: "foreword",
            children: [],
          }
        end

        if pref.introduction
          children << {
            id: pref.introduction.id || "introduction",
            title: extract_title(pref.introduction) || "Introduction",
            type: "introduction",
            children: [],
          }
        end

        children
      end

      def build_body_children
        children = []
        clause_num = 1

        # 1. Scope (clause with type="scope" under <sections>)
        scope = find_scope_clause
        if scope
          children << build_clause_node(scope, clause_num)
          clause_num += 1
        end

        # 2. Normative references (from <bibliography><references normative="true">)
        norm_refs = find_normative_references
        if norm_refs
          id = norm_refs.is_a?(Struct) ? norm_refs.id : norm_refs.id
          children << {
            id: id || "normative_references",
            title: extract_title(norm_refs) || "Normative references",
            type: "normative_references",
            number: clause_num.to_s,
            children: [],
          }
          clause_num += 1
        end

        # 3. Terms and definitions
        secs = @document.sections
        if secs.is_a?(Metanorma::IsoDocument::Sections::IsoSections) && secs.terms
          terms = secs.terms
          children << {
            id: terms.id || "terms",
            title: extract_title(terms) || "Terms and definitions",
            type: "terms",
            number: clause_num.to_s,
            children: build_term_children(terms),
          }
          clause_num += 1
        end

        # 4+ Remaining clauses (non-scope)
        if secs.is_a?(Metanorma::IsoDocument::Sections::IsoSections)
          clauses = Array(secs.clause)
          clauses.each do |clause|
            next if clause.is_a?(Metanorma::IsoDocument::Sections::IsoClauseSection) && clause.type == "scope"

            children << build_clause_node(clause, clause_num)
            clause_num += 1
          end
        end

        children
      end

      def find_scope_clause
        secs = @document.sections
        return nil unless secs.is_a?(Metanorma::IsoDocument::Sections::IsoSections)

        clauses = Array(secs.clause)
        clauses.find { |c| c.is_a?(Metanorma::IsoDocument::Sections::IsoClauseSection) && c.type == "scope" }
      end

      def find_normative_references
        # Get individual references sections from bibliography
        refs = all_references_sections

        # Model has normative attribute on StandardReferencesSection
        norm_ref = refs.find { |r| r.normative == "true" }
        return norm_ref if norm_ref

        # Fallback: use Nokogiri if model doesn't have the data
        if @nokogiri_doc
          ref_node = @nokogiri_doc.at_css("references[normative='true']")
          if ref_node
            id = ref_node["id"]
            match = refs.find { |r| r.id == id }
            return match if match

            title_el = ref_node.at_css("> title")
            return Struct.new(:id, :title, :normative).new(
              id,
              title_el&.text || "Normative references",
              "true",
            )
          end
        end

        nil
      end

      def build_term_children(terms)
        term_list = Array(terms.term)
        return [] unless term_list.any?

        term_list.each_with_index.map do |term, idx|
          preferred = extract_term_name(term)
          {
            id: term.id,
            title: preferred || "Term #{idx + 1}",
            type: "term",
            number: (idx + 1).to_s,
            children: [],
          }
        end
      end

      def extract_term_name(term)
        return nil unless term.is_a?(Metanorma::IsoDocument::Terms::IsoTerm)

        preferreds = Array(term.preferred)
        pref = preferreds.first
        return nil unless pref

        if pref.is_a?(Metanorma::IsoDocument::Terms::TermDesignation)
          exprs = Array(pref.expression)
          name_el = exprs.first
          if name_el.is_a?(Metanorma::IsoDocument::Terms::TermExpression) && name_el.name
            raw = name_el.name
            return raw.text if raw.is_a?(Metanorma::IsoDocument::Terms::TermNameElement)

            return raw.to_s
          end
        end

        extract_text_from_model(pref)
      end

      def build_clause_node(clause, number, parent_number = nil)
        display_number = parent_number ? "#{parent_number}.#{number}" : number.to_s
        title = extract_title(clause) || "Clause #{display_number}"

        node = {
          id: clause.id,
          title: title,
          type: "clause",
          number: display_number,
          children: [],
        }

        subclauses = clause_clause_children(clause)
        if subclauses.any?
          subclause_num = 1
          subclauses.each do |subclause|
            node[:children] << build_clause_node(subclause, subclause_num,
                                                 display_number)
            subclause_num += 1
          end
        end

        node
      end

      def build_annex_children
        annexes = Array(@document.annex)

        annexes.map.with_index do |annex, index|
          letter = ("A".ord + index).chr
          title = extract_title(annex) || "Annex #{letter}"

          node = {
            id: annex.id,
            title: title,
            type: "annex",
            number: letter,
            obligation: annex.obligation,
            children: [],
          }

          subclauses = clause_clause_children(annex)
          if subclauses.any?
            subclause_num = 1
            subclauses.each do |subclause|
              node[:children] << build_annex_clause_node(subclause,
                                                         subclause_num, letter)
              subclause_num += 1
            end
          end

          node
        end
      end

      def build_annex_clause_node(clause, number, parent_letter)
        display_number = "#{parent_letter}.#{number}"
        title = extract_title(clause)
        inline_header = clause.inline_header

        node = {
          id: clause.id,
          title: title,
          type: "clause",
          number: display_number,
          inline_header: inline_header == "true",
          children: [],
        }

        subclauses = clause_clause_children(clause)
        if subclauses.any?
          subclause_num = 1
          subclauses.each do |subclause|
            node[:children] << build_annex_clause_node(subclause,
                                                       subclause_num, display_number)
            subclause_num += 1
          end
        end

        node
      end

      def build_bibliography_children
        refs = all_references_sections

        refs
          .reject { |r| r.normative == "true" }
          .map do |ref|
            title = extract_title(ref) || "Bibliography"

            {
              id: ref.id || "bibliography",
              title: title,
              type: "bibliography",
              children: [],
            }
          end
      end

      def extract_title(element)
        title = element.title
        return nil unless title

        case title
        when String
          title.empty? ? nil : title
        when Array
          text = title.map { |t| extract_text_from_model(t) }.join
          text.empty? ? nil : text
        when Lutaml::Model::Serializable
          extract_text_from_model(title)
        else
          title.to_s
        end
      end

      def extract_text_from_model(obj)
        return "" if obj.nil?
        return obj if obj.is_a?(String)

        if obj.is_a?(Metanorma::IsoDocument::Terms::TermNameElement)
          return obj.text.to_s
        end

        if obj.is_a?(Lutaml::Model::Serializable)
          # Walk element_order for text nodes
          element_order = obj.element_order
          if element_order.is_a?(Array)
            text_parts = element_order
              .select { |e| e.is_a?(Lutaml::Xml::Element) && e.node_type == :text }
              .map(&:text_content)
            return text_parts.join unless text_parts.empty?
          end
        end

        ""
      end

      # Get clause children that are themselves clauses (sub-sections)
      def clause_clause_children(clause)
        return [] unless clause.clause

        Array(clause.clause)
      end

      # Flatten all references sections from bibliography container(s)
      def all_references_sections
        bibs = Array(@document.bibliography)
        bibs.flat_map { |b| Array(b.references) }
      end
    end
  end
end
