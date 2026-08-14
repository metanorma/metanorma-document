# frozen_string_literal: true

module Metanorma
  module Mirror
    # Single source of truth for the default Metanorma → Mirror handler
    # registrations. `Mirror.default_registry` memoizes a frozen instance
    # built from here; `Mirror.build_default_registry` returns a fresh
    # instance each call.
    #
    # Adding a new model class to handler mapping = adding one
    # `register_default` call here. No edits to HandlerRegistry (OCP).
    module DefaultRegistry
      class << self
        def build
          registry = HandlerRegistry.new
          register_default(registry)
          registry
        end

        private

        def register_default(registry)
          register_paragraphs(registry)
          register_blocks(registry)
          register_lists(registry)
          register_sections(registry)
          register_terms(registry)
          register_structural(registry)
        end

        def register_paragraphs(registry)
          registry.register(
            Metanorma::Document::Components::Paragraphs::ParagraphBlock,
            Handlers::Paragraph,
          )
        end

        def register_blocks(registry)
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
        end

        def register_lists(registry)
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
        end

        def register_sections(registry)
          registry.register(
            Metanorma::Standoc::Document::Sections::ClauseSection,
            Handlers::Section,
            method_name: :clause,
          )
          registry.register(
            Metanorma::Standoc::Document::Sections::AnnexSection,
            Handlers::Section,
            method_name: :annex,
          )
          registry.register(
            Metanorma::Standoc::Document::Sections::ContentSection,
            Handlers::Section,
            method_name: :content_section,
          )
          registry.register(
            Metanorma::Standoc::Document::Sections::TermsSection,
            Handlers::Section,
            method_name: :terms,
          )
          registry.register(
            Metanorma::Iso::Document::Sections::IsoTermsSection,
            Handlers::Section,
            method_name: :terms,
          )
          registry.register(
            Metanorma::Standoc::Document::Sections::DefinitionSection,
            Handlers::Section,
            method_name: :definitions,
          )
          registry.register(
            Metanorma::Standoc::Document::Sections::StandardReferencesSection,
            Handlers::Section,
            method_name: :references,
          )
          registry.register(
            Metanorma::Standoc::Document::Sections::FloatingTitle,
            Handlers::Section,
            method_name: :floating_title,
          )
        end

        def register_terms(registry)
          registry.register(
            Metanorma::Iso::Document::Terms::IsoTerm,
            Handlers::Term,
          )
        end

        def register_structural(registry)
          registry.register(
            Metanorma::Standoc::Document::Sections::Preface,
            Handlers::Structural,
            method_name: :preface,
          )
          # IsoPreface and UnPreface deliberately do not inherit
          # StandardDocument::Preface (grammar-strict classes compose from
          # mixins), so they need explicit registrations — the registry
          # resolves handlers through class ancestry.
          registry.register(
            Metanorma::Iso::Document::Sections::IsoPreface,
            Handlers::Structural,
            method_name: :preface,
          )
if defined?(Metanorma::Un::Document)
          registry.register(
            Metanorma::Un::Document::Sections::UnPreface,
            Handlers::Structural,
            method_name: :preface,
          )
          # UnAbstractSection likewise composes instead of inheriting
          # ContentSection.
          registry.register(
            Metanorma::Un::Document::Sections::UnAbstractSection,
            Handlers::Section,
            method_name: :content_section,
          )
        end
          registry.register(
            Metanorma::Standoc::Document::Sections::Sections,
            Handlers::Structural,
            method_name: :sections,
          )
          registry.register(
            Metanorma::Standoc::Document::Sections::BibliographySection,
            Handlers::Structural,
            method_name: :bibliography,
          )
        end
      end
    end
  end
end
