# frozen_string_literal: true

module Metanorma
  module Html
    class Generator
      @tastes = []
      @resolved_tastes = {}

      class << self
        # The shared flavor registry (Metanorma::Html.flavors). The
        # harness seeds only its own defaults; flavour gems register
        # themselves via Metanorma::Html.register_flavor at load time.
        def flavors
          Metanorma::Html.flavors
        end

        # Register a taste: same document model, different renderer based
        # on publisher. When the document's first author publisher
        # abbreviation matches, the taste renderer takes precedence over
        # the model-based renderer.
        def register_taste(model_class, publisher_abbrev, renderer_class)
          @tastes << [model_class, publisher_abbrev, renderer_class]
        end

        def generate(document, **)
          renderer_for(document).new.generate_full_document(document, **)
        end

        def renderer_for(document)
          taste_renderer = find_taste(document)
          return taste_renderer if taste_renderer

          flavor = Metanorma::Html.flavors.find_for(document.class)
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

        def safe_attr(node, attr_name)
          return nil unless node.is_a?(Lutaml::Model::Serializable)
          return nil unless node.class.attributes.key?(attr_name)

          node.public_send(attr_name)
        end
      end
    end
  end
end
