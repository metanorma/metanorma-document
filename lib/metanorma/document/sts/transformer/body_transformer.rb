# frozen_string_literal: true

module Metanorma
  module Document
    module Sts
      module Transformer
        class BodyTransformer < Base
          def transform(source)
            sections = []

            # Neutral structure: the preface sections (foreword,
            # introduction, boilerplate — see FrontTransformer) live in
            # the body. A publisher whose front carries them replaces
            # this hook with false via its FrontTransformer/BodyTransformer
            # subclasses (the ISO profile does exactly that).
            sections += front_transformer.preface_sections(source) if include_preface_in_body? && source.front?

            source.sections.each do |clause|
              sec = dispatcher.dispatch(clause)
              sections << sec if sec
            end

            ModelBuilder.body(sec: sections)
          end

          # ---- Structure hooks (public extension points) -------------

          # True when the preface sections belong to the body (the
          # neutral document structure).
          def include_preface_in_body?
            true
          end
        end
      end
    end
  end
end
