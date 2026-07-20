# frozen_string_literal: true

module Metanorma
  module Html
    module Concerns
      # Presentation-XML validation mixed into BaseRenderer. HTML
      # generation requires Presentation XML input — semantic XML does not
      # contain the formatting data needed for HTML — so the document is
      # checked for presentation markers before rendering begins.
      module PresentationValidation
        def validate_presentation_xml!
          has_presentation = check_presentation_markers(@document)
          return if has_presentation

          raise ArgumentError,
                "HTML generation requires Presentation XML input. " \
                "Semantic XML does not contain formatting data needed for HTML. " \
                "Use a '.presentation.xml' file instead."
        end

        # Name kept for API stability (public renderer API); the boolean
        # return predates the Naming/PredicateMethod convention.
        # rubocop:disable Naming/PredicateMethod
        def check_presentation_markers(node)
          return false unless node
          return false if node.is_a?(String)

          if node.is_a?(Lutaml::Model::Serializable)
            node_attrs = node.class.attributes
            if node_attrs.key?(:type) && node.type == "presentation"
              return true
            end
            if node_attrs.key?(:fmt_title) && node.fmt_title
              return true
            end
            if node_attrs.key?(:displayorder) && node.displayorder
              return true
            end

            %i[preface sections annex bibliography].each do |attr|
              next unless node_attrs.key?(attr)

              val = node.public_send(attr)
              next unless val

              Array(val).each { |v| return true if check_presentation_markers(v) }
            end

            node.each_mixed_content do |child|
              next if child.is_a?(String)
              return true if check_presentation_markers(child)
            end
          end

          false
        end
        # rubocop:enable Naming/PredicateMethod
      end
    end
  end
end
