# frozen_string_literal: true

require "date"
require "cgi"

module Metanorma
  module Document
    module Presentation
      module Behaviours
        # Writes fmt-date next to each date that has a value. The date's
        # own format is used unless the profile gives a date_format pattern. Dates
        # may be a year, a year-month or a full ISO date; month names
        # are English.
        class DateFormat
          ISO = /\A(\d{4})(?:-(\d{2})(?:-(\d{2}))?)?\z/

          def initialize(format: nil)
            @format = format
          end

          def call(model)
            Walk.each(model) do |node, _path|
              next unless node.class.attributes.key?(:date) && node.class.attributes.key?(:fmt_date)

              dates = Array(node.date)
              next if dates.empty?

              made = dates.map { |d| fmt(d) }
              out = made.compact
              next if out.empty?

              node.fmt_date = out
              place_after_dates(node, made)
            end
            model
          end

          private

          # In mixed content the generated element follows its date, as in
          # isodoc's output. Without a recorded order it is appended.
          def place_after_dates(node, made)
            order = node.element_order
            return unless order

            k = -1
            node.element_order = order.reject { |e| e.name == "fmt-date" }.flat_map do |e|
              next [e] unless e.name == "date" && e.type == "Element"

              k += 1
              made[k] ? [e, Lutaml::Xml::Element.new("Element", "fmt-date")] : [e]
            end
          end

          def fmt(date)
            pattern = @format || date.format&.strip
            return nil unless date.value && pattern && !pattern.empty?

            text = render(date.value, pattern)
            Components::Inline::FmtDateElement.from_xml(
              %(<fmt-date><semx element="date">#{CGI.escapeHTML(text)}</semx></fmt-date>),
            )
          end

          def render(value, pattern)
            m = ISO.match(value.to_s.strip) or return value.to_s
            parsed = Date.new(m[1].to_i, (m[2] || 1).to_i, (m[3] || 1).to_i)
            parsed.strftime(pattern)
          rescue Date::Error
            value.to_s
          end
        end
      end
    end
  end
end
