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
