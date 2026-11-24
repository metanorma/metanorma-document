# frozen_string_literal: true

require "date"
require "isodoc-i18n"
require "cgi"

module Metanorma
  module Document
    module Presentation
      module Behaviours
        # Writes fmt-date next to each date that has a value. The date's
        # own format is used unless the profile gives a date_format pattern. Dates
        # may be a year, a year-month or a full ISO date. Month names are
        # English, or in the language date_language names ("document":
        # the language of the bibdata), through isodoc-i18n.
        class DateFormat
          ISO = /\A(\d{4})(?:-(\d{2})(?:-(\d{2}))?)?\z/

          def initialize(format: nil, language: nil)
            @format = format
            @language = language
          end

          def call(model)
            @i18n = i18n_for(model)
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

          def i18n_for(model)
            return unless @language

            lang = @language == "document" ? Bibdata::Document.language(model) : @language
            return if lang.to_s.empty? || lang == "en"

            script = Bibdata::Document.script(model)
            IsoDoc::I18n.new(lang, script.empty? ? "Latn" : script)
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
            return @i18n.date(value.to_s.strip, pattern) if @i18n

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
