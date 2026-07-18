# frozen_string_literal: true

module Metanorma
  module Html
    module Renderers
      class PubidRenderer
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

        # Flavor identity comes from the shared FlavorRegistry via the
        # coordinator — no local duplicate of the flavor-to-pubid-module
        # map.
        def resolve_pubid_module
          @coordinator.pubid_module
        end
      end
    end
  end
end
