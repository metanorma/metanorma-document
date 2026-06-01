# frozen_string_literal: true

require "liquid"
require "nokogiri"

module Metanorma
  module Html
    unless defined?(TEMPLATES_ROOT)
      TEMPLATES_ROOT = File.join(__dir__, "html", "templates")

      Liquid::Environment.default.file_system = Liquid::LocalFileSystem.new(
        TEMPLATES_ROOT, "_%s.html.liquid"
      )

      Moxml::Adapter::Nokogiri.class_eval do
        class << self
          alias_method :_original_children_patched, :children
          remove_method :children
        end

        def self.children(node)
          node.children.to_a
        end
      end
    end

    # Patch missing Moxml module method used by lutaml-model XML serializer
    ::Moxml.class_eval do
      def self.preprocess_entities(text)
        if block_given?
          yield text
        else
          text
        end
      end
    end

    module Html
      Lutaml::Xml::XmlElement.class_eval do
        remove_method :order

        def order
          return @order_cache if @order_cache

          @order_cache = children.filter_map do |child|
            if child.text?
              Lutaml::Xml::Element.new("Text", "text",
                                       text_content: child.text,
                                       node_type: :text)
            elsif child.cdata?
              Lutaml::Xml::Element.new("Text", "#cdata-section",
                                       text_content: child.text,
                                       node_type: :cdata)
            elsif child.comment?
              nil
            else
              Lutaml::Xml::Element.new("Element", child.unprefixed_name,
                                       node_type: :element,
                                       namespace_uri: child.namespace_uri,
                                       namespace_prefix: child.namespace_prefix)
            end
          end
        end
      end
    end

    autoload :BaseRenderer, "metanorma/html/base_renderer"
    autoload :Generator, "metanorma/html/generator"
    autoload :Theme, "metanorma/html/theme"
    autoload :AssetPipeline, "metanorma/html/asset_pipeline"
    autoload :Component, "metanorma/html/component"
    autoload :Drops, "metanorma/html/drops"
    autoload :StandardRenderer, "metanorma/html/standard_renderer"
    autoload :IsoRenderer, "metanorma/html/iso_renderer"
    autoload :BipmRenderer, "metanorma/html/bipm_renderer"
    autoload :CcRenderer, "metanorma/html/cc_renderer"
    autoload :IccRenderer, "metanorma/html/icc_renderer"
    autoload :PdfaRenderer, "metanorma/html/pdfa_renderer"
    autoload :IecRenderer, "metanorma/html/iec_renderer"
    autoload :IeeeRenderer, "metanorma/html/ieee_renderer"
    autoload :IetfRenderer, "metanorma/html/ietf_renderer"
    autoload :IhoRenderer, "metanorma/html/iho_renderer"
    autoload :ItuRenderer, "metanorma/html/itu_renderer"
    autoload :OgcRenderer, "metanorma/html/ogc_renderer"
    autoload :OimlRenderer, "metanorma/html/oiml_renderer"
    autoload :RiboseRenderer, "metanorma/html/ribose_renderer"
  end
end
