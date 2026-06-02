# frozen_string_literal: true

module Metanorma
  module Mirror
    class Error < StandardError; end

    autoload :Node, "#{__dir__}/mirror/node"
    autoload :Mark, "#{__dir__}/mirror/mark"
    autoload :Transformer, "#{__dir__}/mirror/transformer"
    autoload :MetanormaToMirror, "#{__dir__}/mirror/metanorma_to_mirror"
    autoload :MirrorToMetanorma, "#{__dir__}/mirror/mirror_to_metanorma"
    autoload :HandlerRegistry, "#{__dir__}/mirror/handler_registry"
    autoload :SafeAttr, "#{__dir__}/mirror/safe_attr"
    autoload :Handlers, "#{__dir__}/mirror/handlers"
    autoload :Output, "#{__dir__}/mirror/output"
    autoload :Serialization, "#{__dir__}/mirror/serialization"

    def self.default_registry
      registry = HandlerRegistry.new

      # Paragraphs
      registry.register(
        Metanorma::Document::Components::Paragraphs::ParagraphBlock,
        Handlers::Paragraph,
      )

      # Blocks
      registry.register(
        Metanorma::Document::Components::Blocks::NoteBlock,
        Handlers::Note,
      )
      registry.register(
        Metanorma::Document::Components::MultiParagraph::AdmonitionBlock,
        Handlers::Admonition,
      )
      registry.register(
        Metanorma::Document::Components::AncillaryBlocks::ExampleBlock,
        Handlers::Example,
      )
      registry.register(
        Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
        Handlers::Figure,
      )
      registry.register(
        Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock,
        Handlers::Sourcecode,
      )
      registry.register(
        Metanorma::Document::Components::AncillaryBlocks::FormulaBlock,
        Handlers::Formula,
      )
      registry.register(
        Metanorma::Document::Components::MultiParagraph::QuoteBlock,
        Handlers::Quote,
      )
      registry.register(
        Metanorma::Document::Components::Tables::TableBlock,
        Handlers::Table,
      )
      registry.register(
        Metanorma::Document::Components::MultiParagraph::ReviewBlock,
        Handlers::Review,
      )

      # Lists
      registry.register(
        Metanorma::Document::Components::Lists::UnorderedList,
        Handlers::List,
        method_name: :bullet,
      )
      registry.register(
        Metanorma::Document::Components::Lists::OrderedList,
        Handlers::List,
        method_name: :ordered,
      )
      registry.register(
        Metanorma::Document::Components::Lists::DefinitionList,
        Handlers::List,
        method_name: :definition,
      )
      registry.register(
        Metanorma::Document::Components::Lists::ListItem,
        Handlers::List,
        method_name: :list_item,
      )

      # Sections
      registry.register(
        Metanorma::StandardDocument::Sections::ClauseSection,
        Handlers::Section,
        method_name: :clause,
      )
      registry.register(
        Metanorma::StandardDocument::Sections::AnnexSection,
        Handlers::Section,
        method_name: :annex,
      )
      registry.register(
        Metanorma::StandardDocument::Sections::ContentSection,
        Handlers::Section,
        method_name: :content_section,
      )
      registry.register(
        Metanorma::StandardDocument::Sections::TermsSection,
        Handlers::Section,
        method_name: :terms,
      )
      registry.register(
        Metanorma::IsoDocument::Sections::IsoTermsSection,
        Handlers::Section,
        method_name: :terms,
      )
      registry.register(
        Metanorma::IsoDocument::Terms::IsoTerm,
        Handlers::Term,
      )
      registry.register(
        Metanorma::StandardDocument::Sections::DefinitionSection,
        Handlers::Section,
        method_name: :definitions,
      )
      registry.register(
        Metanorma::StandardDocument::Sections::StandardReferencesSection,
        Handlers::Section,
        method_name: :references,
      )

      # Structural containers
      registry.register(
        Metanorma::StandardDocument::Sections::Preface,
        Handlers::Structural,
        method_name: :preface,
      )
      registry.register(
        Metanorma::StandardDocument::Sections::Sections,
        Handlers::Structural,
        method_name: :sections,
      )
      registry.register(
        Metanorma::StandardDocument::Sections::BibliographySection,
        Handlers::Structural,
        method_name: :bibliography,
      )

      # Floating title
      registry.register(
        Metanorma::StandardDocument::Sections::FloatingTitle,
        Handlers::Section,
        method_name: :floating_title,
      )

      registry
    end
  end
end
