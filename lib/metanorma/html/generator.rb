# frozen_string_literal: true

module Metanorma
  module Html
    class Generator
      @tastes = []
      @resolved_tastes = {}
      @setup = false

      class << self
        # Returns the full FlavorRegistry built from setup!. Read-only
        # access for BaseRenderer, PubidRenderer, and any consumer that
        # needs flavor identity.
        def flavors
          setup! unless @setup
          @flavors
        end

        # Register a taste: same document model, different renderer based
        # on publisher. When the document's first author publisher
        # abbreviation matches, the taste renderer takes precedence over
        # the model-based renderer.
        def register_taste(model_class, publisher_abbrev, renderer_class)
          @tastes << [model_class, publisher_abbrev, renderer_class]
        end

        def generate(document, **)
          setup! unless @setup
          renderer_for(document).new.generate_full_document(document, **)
        end

        def renderer_for(document)
          setup! unless @setup

          taste_renderer = find_taste(document)
          return taste_renderer if taste_renderer

          flavor = @flavors.find_for(document.class)
          flavor&.renderer_class || BaseRenderer
        end

        private

        def find_taste(document)
  @tastes.each do |model_class, publisher_abbrev, renderer_class|
    klass = resolve_model_class(model_class)
    next unless klass && document.is_a?(klass)
    return renderer_class if taste_publisher?(document,
                                              publisher_abbrev)
  end
  nil
end

def resolve_model_class(model_class)
  return model_class if model_class.is_a?(Class)
  return @resolved_tastes[model_class] if @resolved_tastes.key?(model_class)

  flavor = model_class.split("::")[1].to_s.downcase
  begin
    require "metanorma/#{flavor}/document"
  rescue LoadError
    nil
  end
  @resolved_tastes[model_class] =
    Object.const_defined?(model_class) ? Object.const_get(model_class) : nil
end

        def taste_publisher?(document, abbrev)
          bibdata = document.bibdata if document.is_a?(Lutaml::Model::Serializable)
          return false unless bibdata

          contributors = bibdata.contributor
          return false unless contributors

          contributors.any? do |c|
            roles = c.role
            next false unless roles.is_a?(Array)
            next false unless roles.any? { |r| r&.type == "author" }

            org = c.organization
            next false unless org

            org_abbrev = org.abbreviation
            if org_abbrev.is_a?(String)
              org_abbrev == abbrev
            elsif org_abbrev.is_a?(Lutaml::Model::Serializable)
              safe_attr(org_abbrev, :content) == abbrev
            else
              org_abbrev.to_s == abbrev
            end
          end
        end

        def setup!
          return if @setup

          @setup = true
          @flavors = build_flavor_registry

          # Trigger autoloads by referencing constants
          BaseRenderer
          StandardRenderer
          IsoRenderer
          BipmRenderer
          CcRenderer
          CsaRenderer
          IccRenderer
          IecRenderer
          IeeeRenderer
          IetfRenderer
          IhoRenderer
          ItuRenderer
          OgcRenderer
          PdfaRenderer
          RiboseRenderer

          # Register tastes (publisher-based dispatch within same model)
          register_taste "Metanorma::Iso::Document::Root", "ICC", IccRenderer
          register_taste "Metanorma::Ribose::Document::Root", "PDF Association",
                         PdfaRenderer
        end

        # Single source of truth for flavor identity. Each Flavor ties
        # together the model class, the renderer, the symbolic name, and
        # (if applicable) the Pubid module. Adding a new flavor = one
        # entry here.
        def build_flavor_registry
          FlavorRegistry.new.tap do |registry|
            registry.register(Flavor.new(
                                name: nil,
                                model_class: Metanorma::Document::Root,
                                renderer_class: BaseRenderer,
                              ))
            registry.register(Flavor.new(
                                name: nil,
                                model_class: Metanorma::StandardDocument::Root,
                                renderer_class: StandardRenderer,
                              ))
            registry.register(Flavor.new(
                                name: :iso,
                                model_class: "Metanorma::Iso::Document::Root",
                                renderer_class: IsoRenderer,
                                pubid_module: :"Pubid::Iso",
                              ))
            registry.register(Flavor.new(
                                name: :bipm,
                                model_class: "Metanorma::Bipm::Document::Root",
                                renderer_class: BipmRenderer,
                              ))
            registry.register(Flavor.new(
                                name: :cc,
                                model_class: "Metanorma::Cc::Document::Root",
                                renderer_class: CcRenderer,
                              ))
            registry.register(Flavor.new(
                                name: :csa,
                                model_class: "Metanorma::Csa::Document::Root",
                                renderer_class: CsaRenderer,
                                pubid_module: :"Pubid::Csa",
                              ))
            registry.register(Flavor.new(
                                name: :iec,
                                model_class: "Metanorma::Iec::Document::Root",
                                renderer_class: IecRenderer,
                                pubid_module: :"Pubid::Iec",
                              ))
            registry.register(Flavor.new(
                                name: :ieee,
                                model_class: "Metanorma::Ieee::Document::Root",
                                renderer_class: IeeeRenderer,
                                pubid_module: :"Pubid::Ieee",
                              ))
            registry.register(Flavor.new(
                                name: :ietf,
                                model_class: "Metanorma::Ietf::Document::Root",
                                renderer_class: IetfRenderer,
                              ))
            registry.register(Flavor.new(
                                name: :iho,
                                model_class: "Metanorma::Iho::Document::Root",
                                renderer_class: IhoRenderer,
                                pubid_module: :"Pubid::Iho",
                              ))
            registry.register(Flavor.new(
                                name: :itu,
                                model_class: "Metanorma::Itu::Document::Root",
                                renderer_class: ItuRenderer,
                                pubid_module: :"Pubid::Itu",
                              ))
            registry.register(Flavor.new(
                                name: :ogc,
                                model_class: "Metanorma::Ogc::Document::Root",
                                renderer_class: OgcRenderer,
                              ))
            registry.register(Flavor.new(
                                name: :pdfa,
                                model_class: "Metanorma::Ribose::Document::Root",
                                renderer_class: PdfaRenderer,
                              ))
            registry.register(Flavor.new(
                                name: :ribose,
                                model_class: "Metanorma::Ribose::Document::Root",
                                renderer_class: RiboseRenderer,
                              ))
          end
        end

        def safe_attr(node, attr_name)
          return nil unless node.is_a?(Lutaml::Model::Serializable)
          return nil unless node.class.attributes.key?(attr_name)

          node.public_send(attr_name)
        end
      end
    end
  end
end
