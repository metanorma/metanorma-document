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
            parsed: nil,
            title: title || File.basename(xml_path, ".*"),
            content: nil,
            id_strategy: id_strategy,
          )
        end

        def process
          guide = {}
          @steps.reduce(guide) do |current, step_class|
            step_class.new.call(current, @context)
          end
        end

        module Steps
          class ParseXml
            def call(guide, context)
              flavor = context.flavor || infer_flavor(context.xml_path)
              doc_class = flavor_class(flavor)
              xml_content = File.read(context.xml_path)
              context.parsed = doc_class.from_xml(xml_content)
              guide
            end

            def self.flavor_map
              @flavor_map ||= Metanorma.constants.each_with_object({}) do |c, map|
                next unless c.to_s.end_with?("Document")

                flavor = c.to_s.sub(/Document\z/, "").downcase
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
            def call(guide, context)
              id_strategy = context.id_strategy || Mirror::DEFAULT_ID_STRATEGY
              transformer = Mirror::Transformer.new(id_strategy: id_strategy)
              mirror_node = transformer.from_metanorma(context.parsed)
              context.content = mirror_node
              guide["content"] = mirror_node["content"] || []
              guide
            end
          end

          class AttachMetadata
            def call(guide, context)
              parsed = context.parsed

              if parsed.is_a?(Metanorma::StandardDocument::Root)
                bibdata = parsed.bibdata
                if bibdata
                  guide["meta"] ||= {}
                  guide["meta"]["title"] = Handlers.extract_bibdata_title(bibdata)
                  guide["meta"]["flavor"] = context.flavor if context.flavor
                end
              end

              guide["title"] = context.title
              guide
            end

          end
        end
      end
    end
  end
end
