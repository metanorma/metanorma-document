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

          parts = []
          publisher = identifier.publisher
          parts << "<span class=\"ref-publisher-name\">#{escape_html(publisher)}</span>" if publisher

          number = identifier.number
          parts << "<span class=\"ref-doc-number\">#{escape_html(number.to_s)}</span>" if number

          date = identifier.date
          parts << ":<span class=\"ref-year\">#{escape_html(date.to_s)}</span>" if date

          parts.join(" ")
        end

        private

        def escape_html(text)
          @coordinator.escape_html(text)
        end

        def resolve_pubid_module
          flavor_name = @coordinator.flavor_name
          return nil unless flavor_name

          module_name = FLAVOR_PUBID_MAP.find { |_, _| true }&.first # placeholder
          # Look up from the renderer class hierarchy
          @coordinator.class.ancestors.each do |ancestor|
            next unless ancestor.is_a?(Class)

            ns = ancestor.name&.split("::")&.detect { |n| FLAVOR_PUBID_MAP.key?(n) }
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
