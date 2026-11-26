# frozen_string_literal: true

module Metanorma
  module Document
    module Sts
      module Transformer
        class DocumentTransformer < Base
          def transform(source)
            pre_register_reference_ids(source)
            front_model = build_front(source)
            body_model = build_body(source)
            back_model = build_back(source)

            ModelBuilder.standard(
              lang: context.language,
              dtd_version: dtd_version,
              front: front_model,
              body: body_model,
              back: back_model,
            )
          end

          def transform_to_xml(source)
            std = transform(source)
            xml = std.to_xml
            inject_namespaces(xml)
              .then { |x| inject_processing_meta(x) }
              .then { |x| fix_lang_attribute(x) }
              .then { |x| apply_nbsp(x) }
          end

          # ---- Profile-parameterized hooks (public extension points) --

          # The @dtd-version written on <standard>. Publisher data:
          # profiles pin different values (ISO "1.0", OIML "1.2").
          def dtd_version
            context.profile.dtd_version
          end

          # Publisher typography step after serialization. The neutral
          # engine default is a no-op; the ISO profile applies the
          # guidelines' NBSP typography via its subclass.
          def apply_nbsp(xml)
            xml
          end

          private

          # Reference anchors are xref targets from anywhere in the
          # document (norm-refs and bibliography entries alike); register
          # their kind before any transform so ref_type_for sees the kind
          # regardless of section order. Normative entries register as
          # "norm-ref" (cited inline as <std>), bibliography as "ref".
          def pre_register_reference_ids(source)
            (Array(source.sections) + Array(source.bibliography)).each do |s|
              next unless s.class.name.include?("References") ||
                s.class.name.include?("Bibliography")

              normative = reference_transformer.normative_section?(s)
              refs = Array(s.references)
              refs.each do |b|
                next if b.id.nil? || b.id.empty?

                if normative
                  id_generator.register(b.id, b.id, "norm-ref")
                  id_generator.register_normative_ref(
                    b.id, reference_transformer.reference_identity(b)
                  )
                else
                  id_generator.register(b.id, b.id, "ref")
                end
              end
            end
          end

          def build_front(source)
            return nil unless source.has_metadata?

            front_transformer.transform(source)
          end

          def build_body(source)
            context.build(BodyTransformer).new(context).transform(source)
          end

          def build_back(source)
            return nil unless source.has_back?

            context.build(BackTransformer).new(context).transform(source)
          end

          def inject_namespaces(xml)
            Metanorma::Document::Sts.inject_namespaces(xml)
          end

          def inject_processing_meta(xml)
            Metanorma::Document::Sts.inject_processing_meta(xml, context.profile)
          end

          def fix_lang_attribute(xml)
            Metanorma::Document::Sts.fix_lang_attribute(xml)
          end
        end
      end
    end
  end
end
