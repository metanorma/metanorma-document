# frozen_string_literal: true

module Metanorma
  module Document
    module Presentation
      module Behaviours
        # Numbers the top-level sections of a document (displayorder) in
        # the order the profile lists its regions. Regions:
        #
        #   boilerplate_clauses  clauses inside boilerplate statements
        #   preface              every preface section, in document order
        #   scope                the scope clause
        #   normref              the normative references
        #   terms                sections that hold terms
        #   definitions          sections that hold definitions, no terms
        #   middle               the remaining main sections
        #   main                 all main sections not named above, in
        #                        document order (instead of terms,
        #                        definitions and middle)
        #   annex, bibliography, indexsect, colophon
        #
        # Sections the profile does not list get no number. The generated
        # table of contents is not placed here.
        class DisplayOrder
          REGIONS = %w[boilerplate_clauses preface scope normref terms definitions
                       middle main annex bibliography indexsect colophon].freeze
          FLOATING = "FloatingTitle"
          SINGLE = %i[scope normref].freeze

          def initialize(regions:)
            @regions = regions
          end

          def call(model)
            return model unless model.respond_to?(:sections)

            groups = main_groups(model)
            index = 0
            @regions.each do |region|
              Array(nodes_for(region, model, groups)).each do |node|
                next unless numbered?(node)

                node.displayorder = (index += 1)
              end
            end
            model
          end

          private

          def numbered?(node)
            node.class.attributes.key?(:displayorder) && !node.class.name.to_s.end_with?(FLOATING)
          end

          def nodes_for(region, model, groups)
            case region
            when "boilerplate_clauses" then boilerplate_clauses(model)
            when "preface" then Walk.children_in_order(model.preface)
            when "annex" then Array(model.annex)
            when "bibliography" then Walk.children_in_order(model.bibliography).first(1)
            when "indexsect" then Array(model.indexsect)
            when "colophon" then Walk.children_in_order(model.colophon)
            else groups.fetch(region.to_sym, [])
            end
          end

          def boilerplate_clauses(model)
            return [] unless model.respond_to?(:boilerplate) && model.boilerplate

            Walk.children_in_order(model.boilerplate).flat_map do |statement|
              Walk.children_in_order(statement).select { |c| c.class.attributes.key?(:subsection) }
            end
          end

          # Main sections sorted into the regions isodoc distinguishes.
          def main_groups(model)
            groups = Hash.new { |h, k| h[k] = [] }
            Walk.children_in_order(model.sections).each do |node|
              kind = classify(node)
              if SINGLE.include?(kind)
                groups[kind] << node if groups[kind].empty?
                next
              end
              groups[kind] << node
              groups[:main] << node
            end
            groups
          end

          def classify(node)
            if node.class.attributes.key?(:type) && node.type == "scope" then :scope
            elsif references?(node) && node.respond_to?(:normative) && node.normative then :normref
            elsif holds?(node, :terms) then :terms
            elsif holds?(node, :definitions) then :definitions
            else :middle
            end
          end

          def references?(node)
            node.class.attributes.key?(:references) || node.class.attributes.key?(:normative)
          end

          def holds?(node, name)
            pattern = name == :terms ? /TermsSection\z/ : /DefinitionSection\z/
            Walk.each(node).any? { |n, _| n.class.name.to_s.match?(pattern) }
          end
        end
      end
    end
  end
end
