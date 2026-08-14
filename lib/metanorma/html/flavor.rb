# frozen_string_literal: true

require "pubid"

module Metanorma
  module Html
    # A flavor ties together the four concepts that identify a Metanorma
    # document variant:
    # - a symbolic name (used for theme loading, CSS class names)
    # - a model class (the typed root class for the flavor)
    # - a renderer class (the HTML renderer that handles the flavor)
    # - an optional Pubid module (for parsing identifiers like ISO/IEC/etc.)
    #
    # Flavor centralizes flavor identity so BaseRenderer, PubidRenderer,
    # and Generator all read from the same source of truth. Adding a new
    # flavor is one Flavor entry in the registry, not three coordinated
    # edits across three files.
    class Flavor
      attr_reader :name, :renderer_class, :pubid_module

      def initialize(name:, model_class:, renderer_class:, pubid_module: nil)
        @name = name
        @model_class = model_class
        @renderer_class = renderer_class
        @pubid_module = pubid_module
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
  @resolved = Object.const_get(@model_class) if Object.const_defined?(@model_class)
  @resolved
end
      # Match by ancestry: a document whose class is the flavor's model
      # class, or any descendant of it, belongs to this flavor. Walks
      # parent classes via is_a? to support subclassing.
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
              "not be resolved — fix the registration in " \
              "Html::Generator.build_flavor_registry"
      end
    end
  end
end
