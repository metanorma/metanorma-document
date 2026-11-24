# frozen_string_literal: true

module Metanorma
  module Document
    module Presentation
      module Behaviours
        # Fills in a person's complete name when the source has none, in
        # the profile's order. A complete name already given is kept.
        # Given names are the forenames, or the formatted initials when
        # there are no forenames. Parts are joined with a space.
        class ContributorNameOrder
          def initialize(order: "given_family")
            @order = order
          end

          def call(model)
            Walk.each(model) do |node, _path|
              next unless node.is_a?(Relaton::FullName)
              next if Array(node.completename&.value).join.strip != ""

              text = compose(node)
              next if text.empty?

              node.completename = Components::DataTypes::LocalizedString.new(value: [text])
            end
            model
          end

          private

          def compose(name)
            given = text_of(name.forename)
            given = text_of(name.formatted_initials) if given.empty?
            family = text_of(name.surname)
            parts = @order == "family_given" ? [family, given] : [given, family]
            parts.reject(&:empty?).join(" ")
          end

          def text_of(value)
            Array(value).map { |v| string_of(v) }.join(" ").strip
          end

          def string_of(item)
            if item.respond_to?(:value) then Array(item.value).join
            elsif item.respond_to?(:content) then Array(item.content).join
            else item.to_s
            end
          end
        end
      end
    end
  end
end
