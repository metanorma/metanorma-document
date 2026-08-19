# frozen_string_literal: true

module Metanorma
  # Registry of known flavors. Format-agnostic: every format adapter
  # (Metanorma::Html today; docx/pdf later) queries it through
  # #renderer_for with its own format key. Flavor gems register via
  # Metanorma.register_flavor; the harness registers only its own
  # defaults.
  class FlavorRegistry
    include Enumerable

    def initialize
      @flavors = []
    end

    def register(flavor)
      @flavors << flavor
      self
    end

    def each(&)
      @flavors.each(&)
    end

    # The most-specific Flavor whose model_class matches the given
    # document class (by ancestry). Most-specific = registered last: we
    # scan in reverse so general flavors (registered first, by the
    # harness) only match if no more specific flavor does.
    def find_for(document_class)
      @flavors.reverse_each.find { |f| f.matches?(document_class) }
    end

    def name_for(document_class)
      find_for(document_class)&.name
    end

    def pubid_module_for(document_class)
      find_for(document_class)&.pubid_module_const
    end

    # Resolve the renderer class for a format: walk matching flavors
    # most-specific-first and return the first that provides a renderer
    # for the format. A flavor registered without an entry for this
    # format falls through to less-specific matches (e.g. a flavor with
    # only a docx renderer still renders html through the Standoc
    # default).
    def renderer_for(format, document, **options)
      @flavors.reverse_each.each do |flavor|
        next unless flavor.matches?(document.class)

        renderer = flavor.renderer_for(format, document, **options)
        return renderer if renderer
      end
      nil
    end
  end
end
