# frozen_string_literal: true

module Metanorma
  module Document
    module Sts
      module Transformer
        # Front matter mapping. The neutral engine default emits a
        # generic <std-meta> (title, identifier, date, permissions, the
        # profile's custom-meta rule) and places NO sections in <front>:
        # the foreword, introduction, and boilerplate go to the body
        # (see BodyTransformer#include_preface_in_body?). A publisher
        # that structures differently — e.g. the IEC/ISO Coding
        # Guidelines' front <sec>s for foreword/introduction — replaces
        # this step with a registered subclass.
        class FrontTransformer < Base
          def transform(source)
            ModelBuilder.front(std_meta: front_meta(source),
                               sec: front_sections(source))
          end

          # ---- Structure hooks (public extension points) -------------

          # The <std-meta> model. Neutral mapping: composed title,
          # docidentifier, pub date, permissions; the profile's
          # +custom_meta+ rule (when set) contributes the custom-meta
          # group (e.g. the OIML doc-series rule).
          def front_meta(source)
            title = source.formatted_title || source.title(type: "main") ||
              source.title
            ModelBuilder.std_meta(
              doc_identifier: source.docidentifier,
              title: title,
              pub_date: source.pub_date,
              permissions: ModelBuilder.permissions(
                holder: source.copyright_holder || source.publisher ||
                        context.profile.org_abbrev,
                year: source.copyright_year || source.pub_date,
              ),
              custom_meta_group: build_custom_meta(source),
            )
          end

          # Sections placed INSIDE <front>. Neutral default: none —
          # nothing about a publisher's front structure is assumed.
          def front_sections(_source)
            []
          end

          # Preface sections carried by the BODY (foreword, introduction,
          # boilerplate) in the neutral structure. Publishers whose
          # front carries the preface (ISO profile) never call this.
          def preface_sections(source)
            sections = []
            sections += build_foreword(source) if source.foreword
            sections += build_introduction(source) if source.introduction
            sections += build_boilerplate(source)
            sections
          end

          def build_foreword(source)
            content = dispatcher.dispatch_section_blocks(source.foreword)
            [ModelBuilder.sec(title: "Foreword", paragraph: content)]
          end

          def build_introduction(source)
            content = dispatcher.dispatch_section_blocks(source.introduction)
            [ModelBuilder.sec(title: "Introduction", paragraph: content)]
          end

          # Boilerplate copyright/feedback statements carry their
          # paragraphs as sections after the foreword/introduction.
          def build_boilerplate(source)
            typed = source.typed_root
            bp = typed.boilerplate
            return [] unless bp

            sections = []
            Array(bp.copyright_statement).each do |cs|
              paragraphs = boilerplate_paragraphs(cs)
              next if paragraphs.empty?

              sections << ModelBuilder.sec(title: "Copyright", paragraph: paragraphs)
            end
            Array(bp.feedback_statement).each do |fs|
              paragraphs = boilerplate_paragraphs(fs)
              next if paragraphs.empty?

              sections << ModelBuilder.sec(title: "Feedback", paragraph: paragraphs)
            end
            sections
          end

          # The profile's custom-meta rule: called with the source
          # document, returns a custom-meta-group model or nil.
          def build_custom_meta(source)
            rule = context.profile.custom_meta
            return nil unless rule

            rule.call(source)
          end

          private

          def boilerplate_paragraphs(statement)
            paragraphs = []
            statement.each_mixed_content do |inner|
              next if inner.is_a?(String)

              Array(inner.paragraphs).each do |p|
                paragraphs << paragraph_transformer.transform(p)
              end
            end
            paragraphs
          end
        end
      end
    end
  end
end
