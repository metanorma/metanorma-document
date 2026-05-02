# frozen_string_literal: true

module Metanorma
  module Html
    class Generator
      @renderers = []
      @tastes = []
      @setup = false

      class << self
        def register(model_class, renderer_class)
          @renderers << [model_class, renderer_class]
        end

        # Register a taste: same document model, different renderer based on publisher.
        # When the document's first author publisher abbreviation matches,
        # the taste renderer takes precedence over the model-based renderer.
        def register_taste(model_class, publisher_abbrev, renderer_class)
          @tastes << [model_class, publisher_abbrev, renderer_class]
        end

        def generate(document, **options)
          setup! unless @setup
          renderer_for(document).new.generate_full_document(document)
        end

        def renderer_for(document)
          setup! unless @setup

          # Check tastes first (publisher-based dispatch)
          taste_renderer = find_taste(document)
          return taste_renderer if taste_renderer

          # Fall back to model-based dispatch (most specific last)
          @renderers.reverse_each do |model_class, renderer_class|
            return renderer_class if document.is_a?(model_class)
          end
          BaseRenderer
        end

        private

        def find_taste(document)
          @tastes.each do |model_class, publisher_abbrev, renderer_class|
            next unless document.is_a?(model_class)
            return renderer_class if taste_publisher?(document, publisher_abbrev)
          end
          nil
        end

        def taste_publisher?(document, abbrev)
          bibdata = document.bibdata if document.is_a?(Lutaml::Model::Serializable)
          return false unless bibdata
          contributors = bibdata.contributor
          return false unless contributors
          contributors.any? do |c|
            next false unless c.role&.any? { |r| r&.type == "author" } rescue false
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
          end rescue false
        end

        def setup!
          return if @setup
          @setup = true

          # Trigger autoloads by referencing constants
          BaseRenderer
          StandardRenderer
          IsoRenderer
          BipmRenderer
          CcRenderer
          IccRenderer
          IecRenderer
          IeeeRenderer
          IetfRenderer
          IhoRenderer
          ItuRenderer
          OgcRenderer
          OimlRenderer
          PdfaRenderer
          RiboseRenderer

          # Register renderers (most general first, most specific last)
          register Metanorma::Document::Root,           BaseRenderer
          register Metanorma::StandardDocument::Root,   StandardRenderer
          register Metanorma::IsoDocument::Root,        IsoRenderer
          register Metanorma::BipmDocument::Root,       BipmRenderer
          register Metanorma::CcDocument::Root,         CcRenderer
          register Metanorma::IecDocument::Root,        IecRenderer
          register Metanorma::IeeeDocument::Root,       IeeeRenderer
          register Metanorma::IetfDocument::Root,       IetfRenderer
          register Metanorma::IhoDocument::Root,        IhoRenderer
          register Metanorma::ItuDocument::Root,        ItuRenderer
          register Metanorma::OgcDocument::Root,        OgcRenderer
          register Metanorma::OimlDocument::Root,       OimlRenderer
          register Metanorma::RiboseDocument::Root,     RiboseRenderer

          # Register tastes (publisher-based dispatch within same model)
          register_taste Metanorma::IsoDocument::Root,    "ICC",            IccRenderer
          register_taste Metanorma::RiboseDocument::Root, "PDF Association", PdfaRenderer
        end
      end
    end
  end
end
