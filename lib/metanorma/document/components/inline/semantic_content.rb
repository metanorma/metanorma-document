# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Iterator that yields only the semantic (canonical) children of a
        # mixed-content element, skipping any rendered-display (`fmt-*`)
        # siblings.
        #
        # Background: in Metanorma presentation XML, every semantic
        # element with locale-sensitive rendering has a `fmt-*` sibling
        # (e.g. `<stem>` + `<fmt-stem>`). When both are present in the
        # same parent, `each_mixed_content` yields both — duplicating
        # the logical content.
        #
        # Usage:
        #
        #   SemanticContent.each(paragraph) do |node|
        #     # yields semantic children only; fmt_* skipped
        #   end
        #
        #   SemanticContent.each(paragraph).to_a   # => Enumerator
        #
        # Consumers that want the rendered form access it directly via
        # `node.fmt_*` attributes — no iterator needed.
        module SemanticContent
          class << self
            def each(element, &block)
              return enum_for(:each, element) unless block

              element.each_mixed_content do |node|
                next if rendered_display?(node)

                yield node
              end
            end

            private

            def rendered_display?(node)
              return false unless node.is_a?(Lutaml::Model::Serializable)

              node.is_a?(RenderedDisplay)
            end
          end
        end
      end
    end
  end
end
