# frozen_string_literal: true

module Metanorma
  module Document
    module Sts
      # Publisher-profile parameter surface for the STS engine.
      #
      # A profile is the single place where a publisher's identity and
      # structural choices live. The engine carries NO publisher
      # assumption: everything that differs between publishers is either
      #
      # - plain configuration (org identity, custom-meta rules, annex
      #   label text, DTD version, the processing-meta element, post-
      #   processing steps, the document-model reader, validator class);
      # - or a registered class override: a subclass of an engine class
      #   that replaces one step of the mapping (structure hooks). The
      #   engine resolves every step through {Profiles} at construction
      #   time, so a flavor ships subclasses and registers them — no
      #   monkey-patching, no engine edits.
      #
      # A flavor gem builds one Profile and registers it:
      #
      #   Metanorma::Document::Sts::Profiles.register(
      #     Metanorma::Document::Sts::Profile.new(
      #       name: :oiml,
      #       org_abbrev: "OIML",
      #       dtd_version: "1.2",
      #       processing_meta: '<processing-meta …/>',
      #       reader_class: Metanorma::Oiml::Document::Root,
      #       validator_class: Metanorma::Oiml::Sts::Validator,
      #       class_overrides: {
      #         Metanorma::Document::Sts::Transformer::FrontTransformer =>
      #           Metanorma::Oiml::Sts::Transformer::FrontTransformer,
      #       },
      #     )
      #   )
      class Profile
        # Rendering identity of the publisher (branded HTML output).
        # +extra+ carries free-form publisher fields the renderer's
        # footer consumes (site_url, site_label, contact_mail,
        # show_series, generator_name).
        Identity = Struct.new(:publisher_name, :publisher_address,
                              :assets_dir, :logo_light, :logo_dark,
                              :version_string, :extra,
                              keyword_init: true)

        attr_reader :name, :org_abbrev, :dtd_version, :processing_meta,
                    :post_processors, :reader_class, :term_classes,
                    :custom_meta, :validator_class, :identity,
                    :class_overrides

        # @param name [Symbol] profile name (:iso, :oiml, …).
        # @param org_abbrev [String, nil] organization abbreviation used
        #   as the copyright-holder fallback when the source document
        #   declares none.
        # @param dtd_version [String] the @dtd-version written on
        #   <standard> (publishers pin different values).
        # @param processing_meta [String, nil] the <processing-meta>
        #   element XML injected after <standard>; nil disables injection.
        # @param post_processors [Array<#call>] XML string post-processing
        #   steps appended to the facade pipeline (e.g. NBSP typography).
        # @param reader_class [Class, nil] the flavor document model's
        #   Root, used by SourceDocument.parse.
        # @param term_classes [Array<Class>] the flavor document model's
        #   term classes whose presentation autonums the source walk
        #   extracts (empty in the neutral profile).
        # @param custom_meta [#call, nil] called with the source document,
        #   returns a custom-meta-group model or nil (e.g. the OIML
        #   doc-series rule).
        # @param validator_class [Class, nil] the flavor validator
        #   (subclass of Sts::Validator); used by the facade's .validate.
        # @param identity [Identity, nil] branded-rendering identity.
        # @param class_overrides [Hash{Class => Class}] structure hooks:
        #   engine base class => replacement subclass. Every engine step
        #   class is constructed through this registry; a flavor may
        #   replace FrontTransformer, BodyTransformer, BlockDispatcher,
        #   DlTransformer, … without touching the engine.
        def initialize(name:, org_abbrev: nil, dtd_version: "1.0",
                       processing_meta: nil, post_processors: [],
                       reader_class: nil, term_classes: [],
                       custom_meta: nil, validator_class: nil,
                       identity: nil, class_overrides: {})
          @name = name
          @org_abbrev = org_abbrev
          @dtd_version = dtd_version
          @processing_meta = processing_meta
          @post_processors = post_processors.freeze
          @reader_class = reader_class
          @term_classes = term_classes.freeze
          @custom_meta = custom_meta
          @validator_class = validator_class
          @identity = identity
          @class_overrides = class_overrides.freeze
          freeze
        end

        # The registered subclass for +base_class+, or +base_class+ when
        # the profile registers no override. This is the resolution point
        # every engine construction site goes through.
        def resolve(base_class)
          class_overrides.fetch(base_class, base_class)
        end

        # True when the profile registered an override for +base_class+.
        def overrides?(base_class)
          class_overrides.key?(base_class)
        end
      end
    end
  end
end
