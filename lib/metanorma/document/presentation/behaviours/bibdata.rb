# frozen_string_literal: true

require "isodoc-i18n"

module Metanorma
  module Document
    module Presentation
      module Behaviours
        # Rules for the bibdata of a presentation document. isodoc does
        # these in its bibdata step; here each is its own rule, driven by
        # profile settings. All of them read the bibdata language and
        # script from the model.
        module Bibdata
          # The language and script of the document: the first of each
          # in bibdata, unless the profile names one.
          module Document
            module_function

            def bibdata(model)
              model.respond_to?(:bibdata) ? model.bibdata : nil
            end

            def first_value(items)
              item = Array(items).first
              item.respond_to?(:value) ? item.value.to_s : item&.to_s
            end

            def language(model)
              first_value(bibdata(model)&.language)
            end

            def script(model)
              first_value(bibdata(model)&.script)
            end
          end

          # Marks the language and script that the document is in with
          # current="true", as isodoc does. The locale has no element in
          # the model and is not marked.
          class Current
            def call(model)
              bib = Document.bibdata(model) or return model

              { language: Document.language(model), script: Document.script(model) }.each do |attr, current|
                next if current.empty?

                Array(bib.public_send(attr)).each do |e|
                  e.current = "true" if e.respond_to?(:current=) && e.value.to_s == current
                end
              end
              model
            end
          end

          # Gives each address that has no formattedAddress one, made from
          # its parts: streets, city, states, country, then the postcode
          # after the last line. The parts are then dropped, as isodoc does.
          class AddressPrecompose
            PARTS = %i[street city state country postcode].freeze

            def call(model)
              bib = Document.bibdata(model) or return model

              Walk.each(bib) do |node, _path|
                next unless node.class.attributes.key?(:formatted_address) && PARTS.all? { |p| node.class.attributes.key?(p) }
                next if node.formatted_address

                lines = lines_for(node)
                next if lines.empty?

                node.formatted_address = Relaton::FormattedAddress.from_lines(lines)
                PARTS.each { |p| node.public_send("#{p}=", node.class.attributes[p].collection? ? [] : nil) }
              end
              model
            end

            private

            def lines_for(addr)
              lines = Array(addr.street).dup
              lines << addr.city if addr.city
              lines.concat(Array(addr.state))
              lines << addr.country if addr.country
              lines[-1] = "#{lines[-1]} #{addr.postcode}" if addr.postcode && !lines.empty?
              lines
            end
          end

          # Adds a translated copy of doctype, stage, substage and edition
          # next to each original, from an isodoc-i18n label set. The
          # original gets language="" and the copy the label language. The
          # label set is the I18n class named in i18n_class (default
          # IsoDoc::I18n); its doctype_dict, stage_dict, substage_dict,
          # edition_ordinal and edition_cardinal entries are used.
          # A base document type (a single element without language)
          # cannot hold a copy and is left as is.
          class Labels
            def initialize(language:, i18n_class: nil)
              @language = language
              @i18n_class = i18n_class
            end

            def call(model)
              bib = Document.bibdata(model) or return model

              lang = @language == "document" ? Document.language(model) : @language
              return model if lang.to_s.empty?

              i18n = klass.new(lang, Document.script(model).then { |s| s.empty? ? "Latn" : s })
              translate_ext(bib, i18n, lang)
              translate_status(bib, i18n, lang)
              translate_edition(bib, i18n, lang)
              model
            end

            private

            def klass
              return IsoDoc::I18n unless @i18n_class

              Object.const_get(@i18n_class)
            end

            def dict(i18n, key)
              d = i18n.get[key]
              d.is_a?(Hash) ? d : {}
            end

            def translate_ext(bib, i18n, lang)
              ext = bib.ext or return
              attr = %i[doctype_element doctype].find { |a| ext.class.attributes.key?(a) } or return
              return unless ext.class.attributes[attr].collection?

              copy(ext, attr, dict(i18n, "doctype_dict"), lang)
            end

            def translate_status(bib, i18n, lang)
              status = bib.status or return
              { stage: "stage_dict", substage: "substage_dict" }.each do |attr, key|
                next unless status.class.attributes.key?(attr)

                copy(status, attr, dict(i18n, key), lang)
              end
            end

            # Each original whose text is in dict gets language="" and is
            # followed by a copy in lang. Done once: a node that already
            # has a copy in lang is skipped.
            def copy(owner, attr, table, lang)
              items = Array(owner.public_send(attr))
              return if items.any? { |i| i.respond_to?(:language) && i.language == lang }

              out = items.flat_map do |item|
                label = table[text_of(item)]
                next [item] unless label && item.respond_to?(:language=)

                item.language = ""
                [item, item.class.new(language: lang, **content_for(item, label))]
              end
              owner.public_send("#{attr}=", out)
            end

            def text_of(item)
              Array(item.value).join.strip
            end

            def content_for(item, label)
              item.class.attributes[:value].collection? ? { value: [label] } : { value: label }
            end

            def translate_edition(bib, i18n, lang)
              items = Array(bib.edition)
              return if items.empty? || items.any? { |e| e.language == lang }

              source = items.find { |e| e.language.to_s.empty? } or return
              text = edition_text(source, i18n) or return
              source.language = ""
              bib.edition = items + [source.class.new(language: lang, content: text)]
            end

            def edition_text(edition, i18n)
              return unless i18n.respond_to?(:edition_ordinal)

              raw = edition.content.to_s
              if i18n.edition_ordinal && raw.match?(/\A\d+\z/)
                i18n.populate("edition_ordinal", { "var1" => raw.to_i })
              elsif i18n.edition_cardinal
                i18n.populate("edition_cardinal", { "var1" => raw })
              end
            end
          end
        end
      end
    end
  end
end
