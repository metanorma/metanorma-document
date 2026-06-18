# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      class Pipeline
        attr_reader :steps, :context

        def initialize(xml_path:, steps: nil, flavor: nil, title: nil, id_strategy: nil)
          @steps = steps || [Steps::ParseXml, Steps::TransformMirror, Steps::AttachMetadata]
          @context = PipelineContext.new(
            xml_path: xml_path,
            flavor: flavor,
            title: title || File.basename(xml_path, ".*"),
            id_strategy: id_strategy,
          )
        end

        def process
          @steps.each { |step_class| step_class.new.call(@context) }
          Model::Guide.new(
            content: @context.content,
            meta: @context.meta,
            title: @context.title,
          )
        end

        module Steps
          class ParseXml
            def call(context)
              flavor = context.flavor || infer_flavor(context.xml_path)
              doc_class = flavor_class(flavor)
              xml_content = File.read(context.xml_path)
              context.parsed = doc_class.from_xml(xml_content)
            end

            def self.flavor_map
              @flavor_map ||= Metanorma.constants.each_with_object({}) do |c, map|
                next unless c.to_s.end_with?("Document")

                flavor = c.to_s.delete_suffix("Document").downcase
                map[flavor] = c.to_s
              end.freeze
            end

            def infer_flavor(xml_path)
              basename = File.basename(xml_path, ".*")
              from_name = basename.split("-").first.to_s.downcase
              return from_name if self.class.flavor_map.key?(from_name)

              File.dirname(xml_path).split("/").reverse_each do |seg|
                prefix = seg.split("-").first.to_s.downcase
                return prefix if self.class.flavor_map.key?(prefix)
              end

              nil
            end

            def flavor_class(flavor)
              class_name = self.class.flavor_map[flavor] || "StandardDocument"
              Metanorma.const_get(class_name).const_get(:Root)
            end
          end

          class TransformMirror
            def call(context)
              id_strategy = context.id_strategy || Mirror::DEFAULT_ID_STRATEGY
              transformer = Mirror::Transformer.new(id_strategy: id_strategy)
              context.content = transformer.from_metanorma(context.parsed)
            end
          end

          class AttachMetadata
            def call(context)
              parsed = context.parsed
              return unless parsed

              bibdata = SafeAttr.read(parsed, :bibdata)
              return unless bibdata

              meta = {}
              meta["title"] = Metadata.title_from_bibdata(bibdata)
              meta["flavor"] = context.flavor if context.flavor
              context.meta = meta
            end
          end
        end
      end
    end
  end
end
