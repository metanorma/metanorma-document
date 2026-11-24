# frozen_string_literal: true

require "cgi"

module Metanorma
  module Document
    module Presentation
      module Behaviours
        # Writes fmt-fn-label on each footnote that has a reference:
        # the reference wrapped in the profile's open and close text,
        # superscript or not. With scope "body" the open and close text
        # is left off inside tables and figures (outside their names).
        class FootnoteMarker
          BOXES = [Components::Tables::TableBlock, Components::AncillaryBlocks::FigureBlock].freeze
          NAMES = %i[name fmt_name].freeze

          def initialize(sup: true, open: "", close: "", scope: "all")
            @sup = sup
            @open = open
            @close = close
            @scope = scope
          end

          def call(model)
            Walk.each(model) do |node, path|
              next unless node.is_a?(Components::Inline::FnElement) && node.reference

              node.fmt_fn_label = label(node, path)
            end
            model
          end

          private

          def label(fnote, path)
            hidden = fnote.hiddenref == true
            inner = hidden ? "" : marker(fnote, delimited?(path))
            Components::Inline::FmtFnLabelElement.from_xml(
              %(<fmt-fn-label><span class="fmt-caption-label">#{inner}</span></fmt-fn-label>),
            )
          end

          def marker(fnote, delimiters)
            num = %(<semx element="autonum" source="#{CGI.escapeHTML(fnote.id.to_s)}">#{CGI.escapeHTML(fnote.reference)}</semx>)
            body = delimiters ? "#{delim(@open)}#{num}#{delim(@close)}" : num
            @sup ? "<sup>#{body}</sup>" : body
          end

          def delim(text)
            text.empty? ? "" : %(<span class="fmt-label-delim">#{CGI.escapeHTML(text)}</span>)
          end

          def delimited?(path)
            return true if @scope == "all"

            !in_box?(path)
          end

          def in_box?(path)
            path.any? { |owner, _| BOXES.any? { |b| owner.is_a?(b) } } &&
              path.none? { |_, attr| NAMES.include?(attr) }
          end
        end
      end
    end
  end
end
