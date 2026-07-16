# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module HtmlRenderers
        module MarkRenderers
          def self.register(registry)
            # Simple-wrap marks: tag and attrs come from the shared Catalog
            # so the Model-side renderer and the XML-side RichHtmlRenderer
            # agree on HTML output.
            Handlers::Inline::Catalog::SIMPLE_WRAPS.each do |mark_type, spec|
              tag = spec[:tag]
              attrs = spec.except(:tag)
              registry.register_mark_handler(mark_type, ->(inner, _mark) {
                HtmlRenderers.wrap(tag, inner, **attrs)
              })
            end

            # Dynamic marks: attrs come from mark.attrs per instance.
            registry.register_mark_handler("link", ->(inner, mark) {
              HtmlRenderers.wrap(:a, inner, href: mark.attrs["href"] || "#")
            })
            registry.register_mark_handler("xref", ->(inner, mark) {
              HtmlRenderers.wrap(:a, inner, href: "##{mark.attrs['target'] || ''}")
            })
            registry.register_mark_handler("eref", ->(inner, mark) {
              HtmlRenderers.wrap(:a, inner, class: "eref",
                                         cite: mark.attrs["citeas"] || "")
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
