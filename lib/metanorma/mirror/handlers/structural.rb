# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Structural
        def self.preface(element, context:)
          attrs = {}
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)
          attrs[:displayorder] = SafeAttr.read(element, :displayorder)

          content = []
          %i[abstract foreword introduction acknowledgements
             executivesummary].each do |attr|
            child = SafeAttr.read(element, attr)
            next unless child

            result = context.registry.handle(child, context: context)
            result.append_to(content)
          end

          element_content = SafeAttr.read(element, :content)
          Array(element_content).each do |child|
            result = context.registry.handle(child, context: context)
            result.append_to(content)
          end

          Handlers.build_node("preface", attrs: attrs.compact, content: content)
        end

        def self.sections(element, context:)
          attrs = {}
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)
          attrs[:displayorder] = SafeAttr.read(element, :displayorder)

          content = []
          %i[clause terms definitions references floating_title].each do |attr|
            collection = SafeAttr.read(element, attr)
            next unless collection

            Array(collection).each do |child|
              result = context.registry.handle(child, context: context)
              result.append_to(content)
            end
          end

          Handlers.build_node("sections", attrs: attrs.compact, content: content)
        end

        def self.bibliography(element, context:)
          attrs = {}
          attrs[:semx_id] = SafeAttr.read(element, :semx_id)

          content = []
          refs = SafeAttr.read(element, :references)
          Array(refs).each do |ref|
            result = context.registry.handle(ref, context: context)
            result.append_to(content)
          end

          Handlers.build_node("bibliography", attrs: attrs.compact, content: content)
        end
      end
    end
  end
end
