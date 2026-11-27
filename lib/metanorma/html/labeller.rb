# frozen_string_literal: true

module Metanorma
  module Html
    # LADL labeling over the parsed document model: projects the
    # document's nodes onto the LADL content tree (Ladl::ContentElement)
    # and labels it through the configured profile.
    #
    # The projection is metanorma-document's own node-to-numbering-tree
    # link. It is TYPED: dispatch happens on real model classes (the
    # metanorma-document components and the standoc document models the
    # flavors parse into), never on feature probes.
    #
    # Elements with labeled descendants declare the context that scopes
    # them (the ISO/IEC-family context names shared by the family
    # profiles). ladl is an optional render-time dependency: it is
    # required lazily here, so only the consumer that configures a
    # labeling profile (a taste or corpus harness) carries the gem.
    class Labeller
      # Resolves optional model classes lazily: the standoc document
      # models are present whenever a flavor document is being labeled.
      def self.model_class(name)
        return nil unless Object.const_defined?(name, false)

        Object.const_get(name, false)
      end

      SECTIONS_CONTAINER_NAMES = [
        "Metanorma::Standoc::Document::Sections::Sections",
      ].freeze

      SECTION_NAMES = [
        "Metanorma::Document::Components::Sections::HierarchicalSection",
        "Metanorma::Document::Components::Sections::BasicSection",
        "Metanorma::Document::Components::Sections::ContentSection",
        "Metanorma::Document::Components::Sections::ReferencesSection",
        "Metanorma::Standoc::Document::Sections::ClauseSection",
        "Metanorma::Standoc::Document::Sections::ReferencesSection",
        "Metanorma::Standoc::Document::Sections::StandardReferencesSection",
      ].freeze

      ANNEX_NAMES = [
        "Metanorma::Standoc::Document::Sections::AnnexSection",
      ].freeze

      # Numbered clause-family sections outside the ClauseSection class:
      # the definitions ("8. DEFINITIONS") and bibliography ("10.
      # REFERENCES") sections number as clauses in IALA documents.
      # The bibliography wrapper holds the numbered references section
      # without consuming a numbering level ("6. REFERENCES" is the
      # StandardReferencesSection inside it).
      BIBLIOGRAPHY_WRAPPER_NAMES = [
        "Metanorma::Standoc::Document::Sections::BibliographySection",
      ].freeze

      CLAUSE_FAMILY_NAMES = [
        "Metanorma::Standoc::Document::Sections::DefinitionSection",
        "Metanorma::Standoc::Document::Sections::Introduction",
        "Metanorma::Standoc::Document::Sections::Acknowledgements",
        "Metanorma::Standoc::Document::Sections::Abstract",
      ].freeze

      STANDOC_CLAUSE_SECTION =
        "Metanorma::Standoc::Document::Sections::ClauseSection"

      BLOCK_KINDS = {
        "Metanorma::Document::Components::Blocks::NoteBlock" => "note",
        "Metanorma::Document::Components::AncillaryBlocks::ExampleBlock" => "example",
        "Metanorma::Document::Components::AncillaryBlocks::FormulaBlock" => "formula",
        "Metanorma::Document::Components::AncillaryBlocks::FigureBlock" => "figure",
        "Metanorma::Document::Components::Tables::TableBlock" => "table",
        "Metanorma::Standoc::Document::Blocks::FigureBlock" => "figure",
        "Metanorma::Standoc::Document::Blocks::TableBlock" => "table",
        "Metanorma::Standoc::Document::Blocks::NoteBlock" => "note",
        "Metanorma::Standoc::Document::Blocks::ExampleBlock" => "example",
        "Metanorma::Standoc::Document::Blocks::FormulaBlock" => "formula",
      }.freeze

      LIST_NAMES = [
        "Metanorma::Document::Components::Lists::OrderedList",
        "Metanorma::Document::Components::Lists::UnorderedList",
        "Metanorma::Standoc::Document::Lists::OrderedList",
        "Metanorma::Standoc::Document::Lists::UnorderedList",
      ].freeze

      # Any flavor document root: the class-name convention is that the
      # document root of a model family is the family's Root class.
      def document_root?(element)
        name = element.class.name
        name == "DocumentRoot" || name.end_with?("::Root")
      end

      # Context associations per projected node type: elements with
      # labeled descendants declare the context that scopes them.
      CONTEXT_FOR = {
        "document" => "DocumentContext",
        "clause" => "ClauseContext",
        "subclause" => "SubclauseContext",
        "annex" => "AnnexContext",
        "annex_clause" => "AnnexClauseContext",
        "list" => "ListContext",
      }.freeze

      SECTIONS_CONTAINER_CHILDREN = %i[introduction clause terms
        definitions references floating_title].freeze

      # The standoc document root members: the preface, the Sections
      # container, the annex collection, and the bibliography wrapper.
      ROOT_CHILDREN = %i[preface sections annex bibliography].freeze

      attr_reader :result

      # @param profile_path [String] path to a LADL `.lml` profile
      # @param labels [Hash{String => String}] label vocabulary for the
      #   profile's `{key}` tokens (the host document's i18n table)
      # @param root [Object] the parsed document model root
      def initialize(profile_path, labels: {}, root:)
        require "ladl"
        profile = Ladl.load_profile(profile_path)
        content = build_content_tree(root)
        @result = Ladl::Runtime::Engine.new(profile, labels: labels).label(content)
      end

      # The local label for a model element (looked up by its id), or
      # nil when the element is unlabeled.
      def local_for(element)
        label = @result.labels_by_element_id[element_id(element)]
        label && label.value
      end

      # The global cross-reference label for a model element, or nil.
      def global_for(element)
        label = @result.labels_by_element_id[element_id(element)]
        label && label.global_value
      end

      private

      # Projects the document model onto the LADL content tree. The
      # bibliography section parses at the root level but labels as part
      # of the numbered body flow: its children hoist into the sections
      # container so they share the body counter.
      def build_content_tree(root)
        project(root, depth: 0, annex: false)
      end

      def project(element, depth:, annex:)
        kind, type = classify(element, depth, annex)
        node = Ladl::ContentElement.new(id: element_id(element), type: type)
        children_of(element, kind).each do |child|
          node.add_child(project(child, **child_params_for(kind, type, depth, annex)))
        end
        # MN 112: "a ContentElement must be associated with a
        # LabelContext object if it has children to be labeled" — the
        # association applies only to elements with LABELED descendants
        # (nodes whose own type is a labeled one), recursively.
        node.label_context = CONTEXT_FOR[type] if labeled_descendants?(node) &&
          CONTEXT_FOR.key?(type)
        node
      end

      # Whether the subtree rooted at this node contains labeled
      # descendants (nodes whose type is a labeled one).
      def labeled_descendants?(node)
        node.children.any? do |child|
          CONTEXT_FOR.key?(child.type) || labeled_descendants?(child)
        end
      end

      # The element identifier: the model's `id` or its `anchor` (the
      # metanorma sections carry anchors).
      def element_id(element)
        if element.class.attributes.key?(:id)
          element.id
        elsif element.class.attributes.key?(:anchor)
          element.anchor
        end
      end

      # Classifies a model element to [kind, LADL type].
      def classify(element, depth, annex)
        name = element.class.name
        if sections_container?(name)
          return [:sections_container, "document"]
        end
        if bibliography_wrapper?(name)
          return [:bibliography_wrapper, undashed(name)]
        end
        if document_root?(element)
          return [:root, "document"]
        end
        if ANNEX_NAMES.include?(name)
          return [:section, "annex"]
        end
        # The document-control (revision-history) clause is not numbered
        # content: deposits render it outside the numbered flow, or omit
        # it entirely. It contributes nothing to the numbering tree.
        if revision_block?(element, name)
          return [:revision_block, "document_control"]
        end
        if model_class_array(SECTION_NAMES).any? { |k| element.is_a?(k) }
          return [:section, depth.zero? ? "clause" : "subclause"]
        end
        if bibliography_wrapper?(element)
          return [:bibliography_wrapper, undashed(name)]
        end
        if model_class_array(CLAUSE_FAMILY_NAMES).any? { |k| element.is_a?(k) }
          return [:section, depth.zero? ? "clause" : "subclause"]
        end
        if model_class_array(LIST_NAMES).any? { |k| element.is_a?(k) }
          return [:list, "list"]
        end
        BLOCK_KINDS.each do |block_name, type|
          klass = self.class.model_class(block_name)
          return [:block, type] if klass && element.is_a?(klass)
        end
        annex ? [:section, annex_section_type(depth)] : [:other, undashed(name)]
      end

      def annex_section_type(depth)
        depth.zero? ? "annex_clause" : "annex_clause"
      end

      def bibliography_wrapper?(name)
        BIBLIOGRAPHY_WRAPPER_NAMES.include?(name)
      end

      def revision_block?(element, name)
        return false unless name == STANDOC_CLAUSE_SECTION

        element.type == "revision"
      end

      def sections_container?(name)
        SECTIONS_CONTAINER_NAMES.include?(name)
      end

      def model_class_array(names)
        names.filter_map { |n| self.class.model_class(n) }
      end

      def child_params_for(kind, type, depth, annex)
        case type
        when "document"
          { depth: 0, annex: false }
        when "clause", "subclause"
          { depth: depth + 1, annex: annex }
        when "annex"
          { depth: 0, annex: true }
        else
          { depth: depth, annex: annex }
        end
      end

      # The bibliography wrapper is transparent: its children project at
      # the wrapper's own depth (the numbered references section does
      # not gain a level).
      def child_params_for_wrapper(depth, annex)
        { depth: depth, annex: annex }
      end

      # Label-relevant model classes: the projected nodes and the
      # labelable assets.
      def relevant_classes
        @relevant_classes ||= (
          model_class_array(SECTION_NAMES) +
          model_class_array(ANNEX_NAMES) +
          model_class_array(LIST_NAMES) +
          BLOCK_KINDS.keys.filter_map { |n| self.class.model_class(n) }
        )
      end

      def relevant?(element)
        relevant_classes.any? { |k| element.is_a?(k) }
      end

      def children_of(element, kind)
        if kind == :bibliography_wrapper
          declared_collections(element, %i[references clause])
        elsif kind == :revision_block
          []
        elsif kind == :root
          # One document scope = one carrier: the root's own
          # DocumentContext association scopes every body section, so
          # the Sections container and the bibliography wrapper are
          # TRANSPARENT here — their children flatten into the root's
          # children and number continuously ("1."-"5.", then
          # "6. REFERENCES").
          ROOT_CHILDREN.flat_map do |accessor|
            declared_members(element, [accessor]).flat_map do |child|
              transparent_children(child)
            end
          end
        elsif kind == :sections_container
          declared_collections(element, SECTIONS_CONTAINER_CHILDREN)
        elsif kind == :section
          section_children(element)
        else
          []
        end
      end

      # Transparent members: the Sections container and the bibliography
      # wrapper contribute their children instead of themselves.
      def transparent_children(child)
        if sections_container?(child.class.name)
          declared_collections(child, SECTIONS_CONTAINER_CHILDREN)
        elsif bibliography_wrapper?(child.class.name)
          Array(child.references)
        else
          [child]
        end
      end

      # Declared members, scalar or collection: each contributes its
      # object(s) to the child list.
      def declared_members(element, accessors)
        accessors.flat_map do |accessor|
          next [] unless element.class.attributes.key?(accessor)

          v = element.public_send(accessor)
          v.nil? ? [] : (v.is_a?(Array) ? v : [v])
        end
      end

      # The model's own declared collections, in the given order.
      def declared_collections(element, accessors)
        accessors.flat_map do |accessor|
          next [] unless element.class.attributes.key?(accessor)

          Array(element.public_send(accessor))
        end
      end

      # Section children: the model's own declared collections, filtered
      # to label-relevant nodes (nested sections, notes, examples,
      # figures, tables, formulas, lists).
      def section_children(element)
        children = []
        element.class.attributes.each_key do |name|
          next if name == "title"

          v = element.public_send(name)
          Array(v).each do |child|
            children << child if child.is_a?(Lutaml::Model::Serializable) &&
              relevant?(child)
          end
        end
        children
      end

      def undashed(name)
        name.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .downcase
      end

      def label_for(element)
        label = @result.labels_by_element_id[element.id]
        label && yield(label)
      end
    end
  end
end
