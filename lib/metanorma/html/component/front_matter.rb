# frozen_string_literal: true

module Metanorma
  module Html
    module Component
      # Front matter is rendered from model data directly. Legacy DOM
      # destinations become explicit Liquid assigns owned by each slot.
      class FrontMatter
        SLOTS = %w[cover titlepage intro].freeze
        PLACEMENTS = (SLOTS + %w[after_cover template]).freeze

        def initialize(renderer, document)
          @renderer = renderer
          @document = document
        end

        def render
          validate_slots!
          @renderer.activate_front_matter_routing
          assigns = @renderer.front_matter_assigns(@document).merge(
            "front_matter" => Drops::FrontMatterDrop.new(@renderer, @document),
          )
          notes = @renderer.front_matter_enabled? ? coverpage_nodes.map { |node| @renderer.render_coverpage_note(node) }.join : ""
          SLOTS.map do |slot|
            content = render_slot(slot, assigns, notes)
            content += boilerplate_html if slot == "cover" && theme.boilerplate_placement == "after_cover"
            content
          end.join
        end

        private

        def theme = @renderer.theme

        def validate_slots!
          unless PLACEMENTS.include?(theme.boilerplate_placement)
            raise ArgumentError, "Unknown boilerplate placement: #{theme.boilerplate_placement}"
          end
          unless SLOTS.include?(theme.cover_notes_slot)
            raise ArgumentError, "Unknown cover notes slot: #{theme.cover_notes_slot}"
          end
          if theme.boilerplate_placement == "template" && !@renderer.front_matter_enabled?
            raise ArgumentError, "Template boilerplate placement requires a front matter template"
          end
          [theme.boilerplate_placement, theme.cover_notes_slot].uniq.each do |slot|
            next if %w[cover after_cover template].include?(slot)
            next if template_for(slot) && !template_for(slot).empty?
            # Notes need a destination only when routing is enabled.
            next if slot == theme.cover_notes_slot && !@renderer.front_matter_enabled?

            raise ArgumentError, "Front matter #{slot} placement requires a template"
          end
        end

        def template_for(slot)
          theme.public_send("#{slot}_template")
        end

        def render_slot(slot, assigns, notes)
          slot_notes = slot == theme.cover_notes_slot ? notes : ""
          slot_boilerplate = slot == theme.boilerplate_placement ? boilerplate_html : ""
          template = template_for(slot)
          if template && !template.empty?
            @renderer.render_liquid(template, assigns.merge(
              "cover_notes_html" => slot_notes,
              "boilerplate_html" => slot_boilerplate,
            ))
          elsif slot == "cover"
            (@renderer.render_coverpage(@document) || "") + slot_notes + slot_boilerplate
          else
            ""
          end
        end

        def boilerplate_html
          @boilerplate_html ||= @document.boilerplate ? @renderer.render_boilerplate(@document).to_s : ""
        end

        def coverpage_nodes
          result = []
          visit(@document, {}, result)
          result
        end

        def visit(node, seen, result)
          return unless node.is_a?(Lutaml::Model::Serializable)
          return if seen[node.object_id]

          seen[node.object_id] = true
          if @renderer.safe_attr(node, :coverpage)
            result << node
          elsif node.mixed?
            node.each_mixed_content { |child| visit(child, seen, result) }
          else
            node.class.attributes.each_key do |name|
              next if %i[bibdata boilerplate metanorma_extension].include?(name)

              Array(node.public_send(name)).each { |child| visit(child, seen, result) }
            end
          end
        end
      end
    end
  end
end
