# frozen_string_literal: true

require "sts"
require "metanorma/document"

module Metanorma
  module Document
    # Shared NISO STS transformer engine (metanorma-document#165,
    # decision metanorma-iso#1760): the common trunk of the ISO/OIML
    # STS transformer trees, parameterized by publisher profile.
    #
    # Public API (all entry points take the profile explicitly):
    #   Metanorma::Document::Sts.convert(xml, profile: my_profile)
    #   Metanorma::Document::Sts.convert_to_model(xml, profile: …)
    #   Metanorma::Document::Sts.validate(xml, profile: …)
    #   Metanorma::Document::Sts.render_html(xml, profile: …)
    #
    # Flavor gems (metanorma-iso, metanorma-oiml, …) register their
    # {Profile} — org identity, custom-meta rules, processing-meta,
    # DTD version — and their structure-hook subclasses (class
    # overrides) via {Profiles}, then expose their own facade modules
    # delegating here. Nothing in the engine assumes ISO structure: a
    # publisher may map the same source into a different document
    # structure entirely through its profile.
    module Sts
      autoload :Version, "metanorma/document/sts/version"
      autoload :VERSION, "metanorma/document/sts/version"
      autoload :Profile, "metanorma/document/sts/profile"
      autoload :Profiles, "metanorma/document/sts/profiles"
      autoload :Transformer, "metanorma/document/sts/transformer"
      autoload :MathmlBuilder, "metanorma/document/sts/mathml_builder"
      autoload :HtmlRenderer, "metanorma/document/sts/html_renderer"
      autoload :ParityValidator, "metanorma/document/sts/parity_validator"
      autoload :Validator, "metanorma/document/sts/validator"
      autoload :ValidationReport, "metanorma/document/sts/validation_report"

      class << self
        # Convert a Metanorma presentation XML string (or anything
        # `SourceDocument.parse` accepts) into a NISO STS XML string,
        # mapped per +profile+.
        #
        # @param input [String, Pathname, #read] the source XML.
        # @param profile [Profile, Symbol] a profile instance or a
        #   registered profile name.
        # @return [String] NISO STS XML.
        def convert(input, profile: Profiles.default)
          model = convert_to_model(input, profile: profile)
          xml = model.to_xml
          # processing-meta is valid per the delivery-gate schema (NISO
          # STS extended-1.2 MathML3); the older extended-1 package had
          # no slot for it.
          inject_namespaces(xml)
            .then { |x| inject_processing_meta(x, profile) }
            .then { |x| fix_lang_attribute(x) }
            .then { |x| run_post_processors(x, profile) }
        end

        # Convert input to the typed Sts::NisoSts::Standard model.
        # Use this when you need the model directly (e.g. passing to the
        # HTML renderer) to avoid the serialize→deserialize roundtrip
        # that can drop XML entities like &lt; in mixed_content contexts.
        #
        # @param input [String, Pathname, #read] the source XML.
        # @param presentation_xml [String, nil] the sibling presentation
        #   XML, when requirement provision tables should come from the
        #   rendered output.
        # @param profile [Profile, Symbol]
        # @return [Sts::NisoSts::Standard] the typed STS model.
        def convert_to_model(input, presentation_xml: nil, profile: Profiles.default)
          prof = resolve_profile(profile)
          xml_string = input.respond_to?(:read) ? input.read : input.to_s
          source = Transformer::SourceDocument.parse(xml_string, profile: prof)
          pres = presentation_xml || (presentation_input?(xml_string) ? xml_string : nil)
          context = Transformer::Context.new(source, presentation_xml: pres,
                                                     profile: prof)
          Transformer::DocumentTransformer.new(context).transform(source)
        end

        # A presentation-typed document carries the rendered requirement
        # provision tables (<fmt-provision>); wiring them into the context
        # makes requirement tables emit 1:1 with the rendered output.
        PRESENTATION_TYPE_RE = /<metanorma\b[^>]*\btype="presentation"/

        def presentation_input?(xml_string)
          PRESENTATION_TYPE_RE.match?(xml_string)
        end

        # Declare the MathML and XLink namespaces on <standard> when
        # absent (each checked independently — documents may carry one
        # and not the other).
        def inject_namespaces(xml)
          missing = []
          missing << 'xmlns:mml="http://www.w3.org/1998/Math/MathML"' unless xml.include?("xmlns:mml")
          missing << 'xmlns:xlink="http://www.w3.org/1999/xlink"' unless xml.include?("xmlns:xlink")
          return xml if missing.empty?

          xml.sub("<standard", "<standard #{missing.join(' ')}")
        end

        # Inject the profile's <processing-meta> element after
        # <standard>. The element text is profile data (publishers
        # declare different coding profiles); nil disables injection.
        def inject_processing_meta(xml, profile)
          prof = resolve_profile(profile)
          return xml if prof.processing_meta.nil?
          return xml if xml.include?("<processing-meta")

          # Linear scan for the end of the first <standard ...> opening tag.
          # Avoids the polynomial regex previously flagged by CodeQL.
          open_start = xml.index("<standard")
          return xml unless open_start

          open_end = xml.index(">", open_start)
          return xml unless open_end

          xml.dup.insert(open_end + 1, "\n  #{prof.processing_meta}")
        end

        def fix_lang_attribute(xml)
          xml.gsub(/\slang="([a-z-]+)"/, ' xml:lang="\\1"')
        end

        # Validate a NISO STS XML string against the profile's
        # constraints (the flavor validator class).
        #
        # @param xml [String, Pathname, #read] the STS XML.
        # @param profile [Profile, Symbol]
        # @return [ValidationReport]
        def validate(xml, profile: Profiles.default)
          prof = resolve_profile(profile)
          validator_class = prof.validator_class
          unless validator_class
            raise ArgumentError,
                  "no validator configured: the profile must set " \
                  "validator_class to the flavor validator"
          end
          validator_class.new.validate(xml)
        end

        # Render an STS model (or XML string) as a branded HTML page.
        #
        # @param model_or_xml [Sts::NisoSts::Standard, String, #read]
        #   a typed STS model or STS XML. Models built programmatically
        #   are round-tripped through to_xml / from_xml so the renderer
        #   sees a typed tree with element_order populated (lutaml-model
        #   only records element_order during XML parsing, and the
        #   renderer's document-order walk relies on it).
        # @param full_document [Boolean] wrap the fragment in the branded
        #   page shell (default); +false+ returns just the body fragment.
        # @param profile [Profile, Symbol]
        # @return [String] HTML.
        def render_html(model_or_xml, full_document: true, profile: Profiles.default)
          html_input = coerce_html_input(model_or_xml)
          renderer_class = resolve_profile(profile)
            .resolve(HtmlRenderer::Ruby)
          renderer_class.new(profile: profile)
            .render(html_input, full_document: full_document)
        end

        # Strings and IO go straight through; typed models are serialized
        # and re-parsed so the renderer walks a tree with element_order set.
        def coerce_html_input(input)
          return input.to_s unless input.is_a?(Lutaml::Model::Serializable)

          input.to_xml
        end

        private

        def resolve_profile(profile_or_name)
          case profile_or_name
          when Profile then profile_or_name
          when Symbol then Profiles.resolve(profile_or_name)
          when nil then Profiles.default
          else
            raise ArgumentError,
                  "profile must be a Metanorma::Document::Sts::Profile, " \
                  "a registered profile name, or nil"
          end
        end

        def run_post_processors(xml, profile)
          resolve_profile(profile).post_processors.reduce(xml) do |acc, proc|
            proc.call(acc)
          end
        end
      end
    end
  end
end
