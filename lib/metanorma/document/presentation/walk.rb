# frozen_string_literal: true

module Metanorma
  module Document
    module Presentation
      # Depth-first walk over a model tree. Yields every model node with
      # its path: the list of [owner, attribute_name] steps from the root.
      module Walk
        module_function

        def each(root, &block)
          return enum_for(:each, root) unless block

          visit(root, [], {}.compare_by_identity, &block)
        end

        # The element children of a node in document order. Uses the
        # recorded element order when the node was parsed from XML, and
        # falls back to attribute order for a node built in code.
        def children_in_order(node)
          return [] unless node.is_a?(Lutaml::Model::Serializable)

          order = node.respond_to?(:element_order) ? node.element_order : nil
          return attribute_children(node) unless order

          to = node.class.mappings_for(:xml).elements.to_h { |r| [r.name.to_s, r.to] }
          taken = Hash.new(0)
          order.filter_map do |entry|
            next unless entry.type == "Element"

            attr = to[entry.name] or next
            item = Array(node.public_send(attr))[taken[attr]]
            taken[attr] += 1
            item if item.is_a?(Lutaml::Model::Serializable)
          end
        end

        def attribute_children(node)
          node.class.attributes.each_key.flat_map { |a| Array(node.public_send(a)) }
            .grep(Lutaml::Model::Serializable)
        end

        def visit(node, path, seen, &block)
          return unless node.is_a?(Lutaml::Model::Serializable)
          return if seen[node]

          seen[node] = true
          yield node, path
          node.class.attributes.each_key do |name|
            value = node.public_send(name)
            Array(value).each { |child| visit(child, path + [[node, name]], seen, &block) }
          end
        end
      end
    end
  end
end
