# frozen_string_literal: true

module Metanorma
  module Html
    module Renderers
      class PubidRenderer
        FLAVOR_PUBID_MAP = {
          "IsoDocument" => :"Pubid::Iso",
          "IecDocument" => :"Pubid::Iec",
          "IeeeDocument" => :"Pubid::Ieee",
          "IhoDocument" => :"Pubid::Iho",
          "ItuDocument" => :"Pubid::Ithu",
          "OimlDocument" => :"Pubid::Oiml",
        }.freeze

        def initialize(coordinator)
          @coordinator = coordinator
        end

        def parse_pubid(docidentifier_string)
          return nil if docidentifier_string.nil? || docidentifier_string.strip.empty?

          flavor_module = resolve_pubid_module
          return nil unless flavor_module

          flavor_module.parse(docidentifier_string)
        rescue StandardError
          nil
        end

        def pubid_to_html(identifier)
          return nil unless identifier

          @coordinator.render_liquid("_pubid_identifier.html.liquid", {
                                       "publisher" => identifier.publisher ? escape_html(identifier.publisher) : nil,
                                       "number" => identifier.number ? escape_html(identifier.number.to_s) : nil,
                                       "date" => identifier.date ? escape_html(identifier.date.to_s) : nil,
                                     })
        end

        private

        def escape_html(text)
          @coordinator.escape_html(text)
        end

        def resolve_pubid_module
          flavor_name = @coordinator.flavor_name
          return nil unless flavor_name

          @coordinator.class.ancestors.each do |ancestor|
            next unless ancestor.is_a?(Class)

            ns = ancestor.name&.split("::")&.detect do |n|
              FLAVOR_PUBID_MAP.key?(n)
            end
            next unless ns

            mod = FLAVOR_PUBID_MAP[ns]
            return Object.const_get(mod.to_s)
          end
          nil
        rescue NameError
          nil
        end
      end
    end
  end
end
