# frozen_string_literal: true

# Metanorma presentation XML → NISO STS XML transformer engine
# (metanorma-document#165). The common trunk of the ISO/OIML STS
# trees; publisher differences live in profiles
# (Metanorma::Document::Sts::Profile).
#
# Architecture:
# - {SourceDocument}: parses input via the profile's reader class
#   (the flavor document model's Root — typed model, on the
#   metanorma-document framework). Zero Nokogiri.
# - {Context}: shared state during one conversion run; carries the
#   profile and resolves every step class through it.
# - {ModelBuilder}: factory methods for sts-ruby model instances.
# - {DocumentTransformer}: orchestrator. Produces a Sts::NisoSts::Standard
#   root via sts-ruby models and serializes via lutaml-model.
# - Per-element transformers walk typed-model source objects and emit
#   sts-ruby model instances. Zero Nokogiri. Each is a public,
#   overridable extension point: flavors subclass and register.
# - {RenderedTextExtractor}: unified text extraction from typed models.
# - {BlockDispatcher}: Open/Closed dispatch by typed model class name.
module Metanorma
  module Document
    module Sts
      module Transformer
        autoload :SourceDocument, "metanorma/document/sts/transformer/source_document"
        autoload :Standard, "metanorma/document/sts/transformer/standard"
        autoload :Context, "metanorma/document/sts/transformer/context"
        autoload :ModelBuilder, "metanorma/document/sts/transformer/model_builder"
        autoload :IdGenerator, "metanorma/document/sts/transformer/id_generator"
        autoload :FootnoteCollector, "metanorma/document/sts/transformer/footnote_collector"
        autoload :Base, "metanorma/document/sts/transformer/base"
        autoload :DocumentTransformer, "metanorma/document/sts/transformer/document_transformer"
        autoload :FrontTransformer, "metanorma/document/sts/transformer/front_transformer"
        autoload :BodyTransformer, "metanorma/document/sts/transformer/body_transformer"
        autoload :BackTransformer, "metanorma/document/sts/transformer/back_transformer"
        autoload :SectionTransformer, "metanorma/document/sts/transformer/section_transformer"
        autoload :ParagraphTransformer, "metanorma/document/sts/transformer/paragraph_transformer"
        autoload :InlineTransformer, "metanorma/document/sts/transformer/inline_transformer"
        autoload :ListTransformer, "metanorma/document/sts/transformer/list_transformer"
        autoload :TableTransformer, "metanorma/document/sts/transformer/table_transformer"
        autoload :FigureTransformer, "metanorma/document/sts/transformer/figure_transformer"
        autoload :FormulaTransformer, "metanorma/document/sts/transformer/formula_transformer"
        autoload :NoteTransformer, "metanorma/document/sts/transformer/note_transformer"
        autoload :QuoteTransformer, "metanorma/document/sts/transformer/quote_transformer"
        autoload :RequirementTransformer, "metanorma/document/sts/transformer/requirement_transformer"
        autoload :ProvisionIndex, "metanorma/document/sts/transformer/provision_index"
        autoload :ReferenceTransformer, "metanorma/document/sts/transformer/reference_transformer"
        autoload :TermTransformer, "metanorma/document/sts/transformer/term_transformer"
        autoload :DlTransformer, "metanorma/document/sts/transformer/dl_transformer"
        autoload :ContentText, "metanorma/document/sts/transformer/content_text"
        autoload :SourceOrder, "metanorma/document/sts/transformer/source_order"
        autoload :BlockDispatcher, "metanorma/document/sts/transformer/block_dispatcher"
        autoload :RenderedTextExtractor, "metanorma/document/sts/transformer/rendered_text_extractor"

        class << self
          # Convert source XML to an STS XML string under +profile+.
          #
          # @param input [String] source presentation XML.
          # @param profile [Profile] publisher profile supplying the reader.
          def convert(input, profile: Metanorma::Document::Sts::Profiles.default)
            prof = profile.is_a?(Symbol) ? Metanorma::Document::Sts::Profiles.resolve(profile) : profile
            source = SourceDocument.parse(input, profile: prof)
            context = Context.new(source, profile: prof)
            DocumentTransformer.new(context).transform_to_xml(source)
          end
        end
      end
    end
  end
end
