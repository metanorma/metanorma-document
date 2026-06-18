# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module HtmlRenderers
        module MarkRenderers
          def self.register(registry)
            registry.register_mark_handler("emphasis", ->(inner, _mark) {
              HtmlRenderers.wrap(:em, inner)
            })
            registry.register_mark_handler("strong", ->(inner, _mark) {
              HtmlRenderers.wrap(:strong, inner)
            })
            registry.register_mark_handler("subscript", ->(inner, _mark) {
              HtmlRenderers.wrap(:sub, inner)
            })
            registry.register_mark_handler("superscript", ->(inner, _mark) {
              HtmlRenderers.wrap(:sup, inner)
            })
            registry.register_mark_handler("code", ->(inner, _mark) {
              HtmlRenderers.wrap(:code, inner)
            })
            registry.register_mark_handler("underline", ->(inner, _mark) {
              HtmlRenderers.wrap(:u, inner)
            })
            registry.register_mark_handler("strike", ->(inner, _mark) {
              HtmlRenderers.wrap(:s, inner)
            })
            registry.register_mark_handler("smallcap", ->(inner, _mark) {
              HtmlRenderers.wrap(:span, inner, style: "font-variant: small-caps")
            })
            registry.register_mark_handler("link", ->(inner, mark) {
              HtmlRenderers.wrap(:a, inner, href: mark.attrs["href"] || "#")
            })
            registry.register_mark_handler("xref", ->(inner, mark) {
              HtmlRenderers.wrap(:a, inner, href: "##{mark.attrs['target'] || ''}")
            })
            registry.register_mark_handler("eref", ->(inner, mark) {
              HtmlRenderers.wrap(:a, inner, class: "eref", cite: mark.attrs["citeas"] || "")
            })
            registry.register_mark_handler("footnote", ->(inner, _mark) {
              HtmlRenderers.wrap(:sup, inner, class: "footnote-inline")
            })
            registry.register_mark_handler("stem", ->(inner, _mark) {
              HtmlRenderers.wrap(:span, inner, class: "stem")
            })
            registry.register_mark_handler("concept", ->(inner, _mark) {
              HtmlRenderers.wrap(:span, inner, class: "concept")
            })
            registry.register_mark_handler("bcp14", ->(inner, _mark) {
              HtmlRenderers.wrap(:span, inner, class: "bcp14")
            })
            registry.register_mark_handler("span", ->(inner, mark) {
              cls = mark.attrs["class_attr"]
              attrs = cls ? { class: cls } : {}
              HtmlRenderers.wrap(:span, inner, **attrs)
            })
          end
        end
      end
    end
  end
end
