# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module HtmlRenderers
        module MarkRenderers
          def self.register(registry); end

          MARK_RENDERERS = {
            "emphasis" => ->(text, _mark) { "<em>#{text}</em>" },
            "strong" => ->(text, _mark) { "<strong>#{text}</strong>" },
            "subscript" => ->(text, _mark) { "<sub>#{text}</sub>" },
            "superscript" => ->(text, _mark) { "<sup>#{text}</sup>" },
            "code" => ->(text, _mark) { "<code>#{text}</code>" },
            "underline" => ->(text, _mark) { "<u>#{text}</u>" },
            "strike" => ->(text, _mark) { "<s>#{text}</s>" },
            "smallcap" => ->(text, _mark) {
              "<span style=\"font-variant: small-caps\">#{text}</span>"
            },
            "link" => ->(text, mark) {
              %(<a href="#{Output::HtmlRenderer.escape_attr(mark.attrs['href'] || '#')}">#{text}</a>)
            },
            "xref" => ->(text, mark) {
              %(<a href="##{Output::HtmlRenderer.escape_attr(mark.attrs['target'] || '')}">#{text}</a>)
            },
            "eref" => ->(text, mark) {
              %(<a class="eref" cite="#{Output::HtmlRenderer.escape_attr(mark.attrs['citeas'] || '')}">#{text}</a>)
            },
            "footnote" => ->(text, _mark) {
              %(<sup class="footnote-inline">#{text}</sup>)
            },
            "stem" => ->(text, _mark) { %(<span class="stem">#{text}</span>) },
            "concept" => ->(text, _mark) {
              %(<span class="concept">#{text}</span>)
            },
            "bcp14" => ->(text, _mark) { %(<span class="bcp14">#{text}</span>) },
            "span" => ->(text, mark) {
              cls = mark.attrs["class_attr"]
              cls_attr = cls ? %( class="#{Output::HtmlRenderer.escape_attr(cls)}") : ""
              %(<span#{cls_attr}>#{text}</span>)
            },
          }.freeze
        end
      end
    end
  end
end
