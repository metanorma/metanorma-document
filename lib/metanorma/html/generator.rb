# frozen_string_literal: true

module Metanorma
  module Html
    class Generator
      class << self
        # The HTML format adapter over the central flavor registry.
        # Renderer selection: the most-specific matching flavor that
        # provides an :html renderer wins (Proc values are flavor-owned
        # variant resolvers — publisher/doctype/profile selection); with
        # no flavor match, the harness default by ancestry. Options are
        # per-call runtime knobs threaded to the resolver.
        def generate(document, **options)
          renderer_for(document, **options)
                 .new.generate_full_document(document, **options)
        end

        def renderer_for(document, **options)
          Metanorma::Core::Flavors.renderer_for(document, format: :html,
                                                **options) || BaseRenderer
        end

        private

      end
    end
  end
end
