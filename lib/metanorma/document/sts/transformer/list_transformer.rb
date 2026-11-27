# frozen_string_literal: true

module Metanorma
  module Document
    module Sts
      module Transformer
        class ListTransformer < Base
          # MN ol @type → NISO STS list-type + the item marker the ISO
          # renderer would paint (Guidelines 5.7.2: list-type reflects the
          # actual numbering — "alphabet" renders "a)", "arabic" "1)").
          ORDERED_SCHEMES = {
            "arabic" => { list_type: "arabic", marker: ->(i) { "#{i + 1})" } },
            "alphabet" => {
              list_type: "alpha-lower",
              marker: lambda { |i|
                letter = ("a".."z").to_a[i]
                letter ? "#{letter})" : "#{i + 1})"
              },
            },
            "roman" => { list_type: "roman-lower", marker: ->(i) { "#{ROMAN[i + 1] || (i + 1)})" } },
          }.freeze
          ROMAN = { 1 => "i", 2 => "ii", 3 => "iii", 4 => "iv", 5 => "v", 6 => "vi",
                    7 => "vii", 8 => "viii", 9 => "ix", 10 => "x" }.freeze

          def transform(source_list)
            ordered = source_list.is_a?(Metanorma::Document::Components::Lists::OrderedList)
            scheme = ordered ? ORDERED_SCHEMES[ordered_type_of(source_list)] : nil
            list_type = if scheme
                          scheme[:list_type]
                        else
                          (ordered ? "arabic" : "bullet")
                        end
            items = Array(source_list.listitem).map.with_index do |li, i|
              build_list_item(li, ordered, scheme && scheme[:marker].call(i))
            end
            ModelBuilder.list(list_type: list_type, list_item: items)
          end

          def transform_def_list(source_dl)
            items = Array(source_dl.dt).zip(Array(source_dl.dd)).filter_map do |dt, dd|
              build_def_item(dt, dd)
            end
            ::Sts::NisoSts::DefList.new(def_item: items)
          end

          private

          def ordered_type_of(source_list)
            return nil unless source_list.class.attributes.key?(:type)

            source_list.type
          end

          def build_list_item(source_item, ordered, fallback_marker = nil)
            nested_lists = build_nested_lists(source_item)

            ::Sts::NisoSts::ListItem.new do |item|
              # Guidelines 5.7.1/5.7.2: ordered items capture their marker
              # in <label>; unordered items carry none (derived on render).
              # The presentation's requirement-subtree lists carry no
              # fmt-name marks, so the marker falls back to type + index.
              label = ordered ? (item_label(source_item) || fallback_marker) : nil
              item.label ::Sts::NisoSts::Label.new(content: [label]) if label
              Array(source_item.paragraphs).each do |p|
                item.p paragraph_transformer.transform(p)
                # MN nests the trailing note INSIDE the item's <p>
                # (<p>text<note>…</note></p>); the STS list-item carries
                # it as an all-notes.class member.
                Array(p.note).each do |n|
                  note = note_transformer.transform(n)
                  item.non_normative_note note if note
                end
              end
              nested_lists.each { |l| item.list l }
              append_item_siblings(source_item, item)
            end
          end

          # MN attaches trailing notes/examples to the list item as typed
          # siblings; the STS list-item model carries them as
          # all-notes.class members.
          def append_item_siblings(source_item, item)
            Array(source_item.note).each do |n|
              note = note_transformer.transform(n)
              item.non_normative_note note if note
            end
            Array(source_item.example).each do |ex|
              example = note_transformer.transform(ex)
              item.non_normative_example example if example
            end
          end

          # The item's marker from the presentation XML (its fmt-name /
          # autonum, e.g. "—" or "1."), nil when absent.
          def item_label(source_item)
            return nil unless source_item.fmt_name

            text = RenderedTextExtractor.text_of(source_item.fmt_name).strip
            text.empty? ? nil : text
          end

          # Recurses into nested <ul>/<ol> children of a list item.
          # MN stores them as typed collection attrs on ListItem.
          def build_nested_lists(source_item)
            results = []
            %i[unordered_lists ordered_lists].each do |attr|
              next unless source_item.class.attributes.key?(attr)

              Array(source_item.public_send(attr)).each do |nested|
                results << transform(nested)
              end
            end
            results
          end

          def build_def_item(dt_element, dd_element)
            term_text = RenderedTextExtractor.text_of(dt_element)
            desc_text = extract_dd_text(dd_element)
            return nil unless term_text || desc_text

            attrs = {}
            attrs[:term] = ::Sts::NisoSts::Term.new(text: [term_text]) if term_text && !term_text.empty?
            if desc_text && !desc_text.empty?
              attrs[:definition] = ::Sts::NisoSts::Def.new(
                paragraph: [::Sts::NisoSts::Paragraph.new(text: [desc_text])],
              )
            end
            ::Sts::NisoSts::DefItem.new(attrs)
          end

          def extract_dd_text(dd_element)
            return nil unless dd_element

            ps = dd_element.p
            ps = Array(ps)
            return RenderedTextExtractor.text_of(dd_element) if ps.empty?

            texts = ps.map { |p| RenderedTextExtractor.text_of(p) }.reject(&:empty?)
            texts.empty? ? nil : texts.join(" ")
          end
        end
      end
    end
  end
end
