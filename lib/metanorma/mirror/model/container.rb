# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      class Container < Node
        def initialize(type: nil, attrs: {}, content: [], **)
          super(type: type, attrs: attrs, **)
          self.content = Array(content)
        end

        def container?
          true
        end

        def text_content
          content.map do |item|
            item.is_a?(String) ? item : item.text_content
          end.join
        end

        def accept_rewriter(rewriter)
          rewriter.rewrite_container(self)
        end
      end

      # content is declared after the sibling node classes exist: the
      # union member list references Container itself, and lutaml-model
      # resolves union members eagerly at declaration time. Deserialized
      # children dispatch through Factory (the child's shape — content
      # array vs leaf vs text — picks the class), which is why the union
      # never receives raw hashes on the way in.
      class Container
        attribute :content, [Text, SoftBreak, Leaf, Container, :string],
                  collection: true, default: -> { [] }

        key_value do
          map "content", to: :content, render_empty: false,
                         with: { from: :content_from_mapping }
        end

        def content_from_mapping(model, value)
          model.content = Array(value).map do |child|
            child.is_a?(Hash) ? Factory.from_hash(child) : child
          end
        end
      end
    end
  end
end
