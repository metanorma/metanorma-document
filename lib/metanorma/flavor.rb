# frozen_string_literal: true

require "pubid"

module Metanorma
  # A flavor ties together the concepts that identify a Metanorma
  # document variant:
  # - a symbolic name (used for theme loading, CSS class names)
  # - a model class (the typed root class for the flavor)
  # - a renderers map, one entry per output format: { html: Renderer }.
  #   A value is either a renderer class (plain resolution) or a Proc
  #   resolver taking (document, **options) and returning the renderer
  #   class — variant selection (publisher, doctype, profile) is
  #   flavor-owned and lives in the resolver.
  # - an optional Pubid module (identifier parsing, format-independent)
  # - optional themes_dir / templates_dir that format adapters overlay
  #
  # Flavor centralizes flavor identity so every format adapter reads
  # from the same source of truth. Adding a flavor is one entry
  # registered via Metanorma.register_flavor — the harness never
  # changes.
  class Flavor
    attr_reader :name, :renderers, :pubid_module, :themes_dir,
                :templates_dir

    def initialize(name: nil, model_class:, renderers: {},
                   pubid_module: nil, themes_dir: nil, templates_dir: nil)
      @name = name
      @model_class = model_class
      @renderers = renderers
      @pubid_module = pubid_module
      @themes_dir = themes_dir
      @templates_dir = templates_dir
    end

    # Resolve the renderer class for a format. Plain class values are
    # returned as-is; Proc values are variant resolvers invoked with the
    # document and the per-call options (selection is flavor-owned).
    def renderer_for(format, document, **options)
      entry = renderers[format]
      return nil unless entry

      entry.is_a?(Proc) ? entry.call(document, **options) : entry
    end

    def model_class
      return @model_class if @model_class.is_a?(Class)
      return @resolved if defined?(@resolved)

      flavor = @model_class.split("::")[1].to_s.downcase
      begin
        require "metanorma/#{flavor}/document"
      rescue LoadError
        nil
      end
      @resolved = if Object.const_defined?(@model_class)
                    Object.const_get(@model_class)
                  end
      @resolved
    end

    # Match by ancestry: a document whose class is the flavor's model
    # class, or any descendant of it, belongs to this flavor.
    def matches?(document_class)
      return false unless document_class.is_a?(Class)

      mc = model_class
      return false unless mc

      # `<=` returns nil for unrelated classes; coerce to boolean.
      !!(document_class <= mc)
    end

    def pubid_module_const
      return nil unless pubid_module

      Object.const_get(pubid_module.to_s)
    rescue NameError
      raise ArgumentError,
            "Flavor #{name.inspect}: pubid module #{pubid_module} could " \
            "not be resolved — fix the flavor's registration"
    end
  end
end
