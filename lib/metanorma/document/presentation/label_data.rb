# frozen_string_literal: true

require_relative "../components/inline/fmt_ladl_label_data"

module Metanorma
  module Document
    module Presentation
      # Engine rule: persists labels computed by a labelling processor
      # (LADL) as fmt-ladl-label-data on the presentation model. This
      # library does not depend on the processor. It only needs a source:
      #
      #   source.call(model) # => [[node, label], ...]
      #
      # where label answers local, global, value, direction,
      # global_direction and labeller, or is nil to clear the node.
      # Persisting follows the LADL native adapter: label data on the node,
      # the generated fmt-xref-label (container "ladl") or plain
      # fmt-xref-label text, autonum, and the list item label.
      class LabelData
        FIELDS = %i[local global value direction global_direction labeller].freeze
        GENERATED_CONTAINER = "ladl"
        Inline = Metanorma::Document::Components::Inline

        def initialize(source:)
          @source = source
        end

        def call(model)
          pairs = @source.call(model).to_a
          validate(pairs)
          pairs.each { |node, label| label ? assign(node, label) : clear(node) }
          model
        end

        private

        # Check every node before any write, so a bad pair changes nothing.
        def validate(pairs)
          pairs.each { |node, label| check(node) if label }
        end

        def check(node)
          return if node.class.respond_to?(:attributes) && node.class.attributes.key?(:fmt_ladl_label_data)

          raise ArgumentError, "#{node.class} cannot hold fmt-ladl-label-data"
        end

        def assign(node, label)
          data = Inline::FmtLadlLabelData.new(**FIELDS.to_h { |key| [key, label.public_send(key)] })
          text = label.global || label.local
          if typed_xref?(node)
            kept = Array(node.fmt_xref_label).reject { |i| i.container == GENERATED_CONTAINER }
            node.fmt_xref_label = kept + [Inline::FmtXrefLabelElement.new(
              container: GENERATED_CONTAINER, text: [text], fmt_ladl_label_data: data,
            )]
          else
            node.fmt_ladl_label_data = data
            node.fmt_xref_label = text if node.class.attributes.key?(:fmt_xref_label)
          end
          node.autonum = label.value if node.class.attributes.key?(:autonum)
          node.label = label.local if node.is_a?(Components::Lists::ListItem)
        end

        def clear(node)
          if typed_xref?(node)
            node.fmt_xref_label = Array(node.fmt_xref_label).reject { |i| i.container == GENERATED_CONTAINER }
          else
            data = node.fmt_ladl_label_data
            return unless data

            node.fmt_ladl_label_data = nil
            node.fmt_xref_label = nil if node.class.attributes.key?(:fmt_xref_label) &&
              node.fmt_xref_label == (data.global || data.local)
            node.autonum = nil if node.class.attributes.key?(:autonum) && node.autonum == data.value
            node.label = nil if node.is_a?(Components::Lists::ListItem) && node.label == data.local
          end
        end

        def typed_xref?(node)
          attr = node.class.attributes[:fmt_xref_label]
          attr && attr.type == Inline::FmtXrefLabelElement && attr.collection?
        end
      end
    end
  end
end
