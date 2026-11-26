# frozen_string_literal: true

module Metanorma
  module Document
    module Sts
      module Transformer
        # Shared wiring for transformer steps. Every step accessor is a
        # public extension point: the instance is constructed through
        # {Context#build}, which resolves the class through the active
        # profile's structure-hook registry — a flavor subclass replaces
        # the engine step by registering itself in its profile
        # (Profile#class_overrides), and every collaborator that asks the
        # context for the step gets the subclass. Overriding the accessor
        # methods themselves also works (return your own instance).
        class Base
          attr_reader :context

          def initialize(context)
            @context = context
          end

          # ---- Collaborator steps (public extension points) ----------

          def source
            context.source
          end

          def id_generator
            context.id_generator
          end

          def dispatcher
            @dispatcher ||= context.build(BlockDispatcher).new(context)
          end

          def paragraph_transformer
            @paragraph_transformer ||= context.build(ParagraphTransformer).new(context)
          end

          def inline_transformer
            @inline_transformer ||= context.build(InlineTransformer).new(context)
          end

          def list_transformer
            @list_transformer ||= context.build(ListTransformer).new(context)
          end

          def table_transformer
            @table_transformer ||= context.build(TableTransformer).new(context)
          end

          def figure_transformer
            @figure_transformer ||= context.build(FigureTransformer).new(context)
          end

          def formula_transformer
            @formula_transformer ||= context.build(FormulaTransformer).new(context)
          end

          def note_transformer
            @note_transformer ||= context.build(NoteTransformer).new(context)
          end

          def quote_transformer
            @quote_transformer ||= context.build(QuoteTransformer).new(context)
          end

          def requirement_transformer
            @requirement_transformer ||= context.build(RequirementTransformer).new(context)
          end

          def reference_transformer
            @reference_transformer ||= context.build(ReferenceTransformer).new(context)
          end

          def section_transformer
            @section_transformer ||= context.build(SectionTransformer).new(context)
          end

          def term_transformer
            @term_transformer ||= context.build(TermTransformer).new(context)
          end

          def dl_transformer
            @dl_transformer ||= context.build(DlTransformer).new(context)
          end

          def front_transformer
            @front_transformer ||= context.build(FrontTransformer).new(context)
          end

          # The model factory. A profile may extend the builders it
          # offers by subclassing {ModelBuilder} and registering the
          # override.
          def model_builder
            ModelBuilder
          end
        end
      end
    end
  end
end
