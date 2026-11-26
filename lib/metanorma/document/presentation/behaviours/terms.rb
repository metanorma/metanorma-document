# frozen_string_literal: true

require "cgi"
require "isodoc-i18n"

module Metanorma
  module Document
    module Presentation
      module Behaviours
        # Rules for terms sections. isodoc does these in its terms step;
        # here each is its own rule, driven by profile settings. Each reads
        # the model's own terms (preferred, admitted, deprecates, domain,
        # definition, termnote, termexample, source) and writes the fmt-*
        # elements that a reader of the presentation document shows.
        module Terms
          KINDS = %w[termnote termexample].freeze

          # Shared helpers: the terms of a model, text and escaping.
          module Support
            module_function

            def esc(text)
              CGI.escapeHTML(text.to_s)
            end

            # Every term with the section it sits in, in document order.
            def each_term(model)
              Walk.each(model) do |node, path|
                next unless node.class.attributes.key?(:fmt_preferred) && node.class.attributes.key?(:definition)

                parent = path.last&.first
                yield node, parent if parent
              end
            end

            def build(owner, attr, xml)
              owner.class.attributes[attr].type.from_xml(xml)
            end

            # The text of a designation: its expression names, else all text.
            def designation_text(designation)
              names = Array(designation.expression).filter_map do |e|
                e.respond_to?(:name) ? Array(e.name).map { |n| text_of(n) }.join : nil
              end
              names.empty? ? text_of(designation) : names.join(" ")
            end

            def text_of(node)
              return node.to_s unless node.is_a?(Lutaml::Model::Serializable)

              xml = node.to_xml
              Nokogiri::XML.fragment(xml).text.strip
            end

            def i18n(model, class_name)
              lang = Bibdata::Document.language(model).to_s
              lang = "en" if lang.empty?
              script = Bibdata::Document.script(model).to_s
              klass = class_name ? Object.const_get(class_name) : IsoDoc::I18n
              klass.new(lang, script.empty? ? "Latn" : script)
            end
          end

          # Numbers each term from the number of its terms section:
          # fmt-name and fmt-xref-label such as "3.1". A terms section
          # without a number is left alone. The delimiter after the number
          # and the "Clause" element name in the cross-reference label
          # are profile settings.
          class Labels
            def initialize(delim: "", element_name: false, i18n_class: nil)
              @delim = delim
              @element_name = element_name
              @i18n_class = i18n_class
            end

            def call(model)
              @i18n = Support.i18n(model, @i18n_class) if @element_name
              Support.each_term(model) do |term, section|
                next unless section.class.attributes.key?(:autonum) && !section.autonum.to_s.empty?

                n = Array(section.term).index { |t| t.equal?(term) } or next
                label(term, section, n + 1)
              end
              model
            end

            private

            def label(term, section, number)
              sec = %(<semx element="autonum" source="#{Support.esc(section.id)}">#{Support.esc(section.autonum)}</semx>)
              own = %(<semx element="autonum" source="#{Support.esc(term.id)}">#{number}</semx>)
              num = %(#{sec}<span class="fmt-autonum-delim">.</span>#{own})
              delim = @delim.empty? ? "" : %(<span class="fmt-clause-delim">#{Support.esc(@delim)}</span>)
              term.fmt_name = Support.build(term, :fmt_name,
                                            %(<fmt-name><span class="fmt-caption-label">#{num}#{delim}</span></fmt-name>))
              term.fmt_xref_label = [Support.build(term, :fmt_xref_label,
                                                   %(<fmt-xref-label>#{prefix}#{num}</fmt-xref-label>))]
            end

            def prefix
              return "" unless @element_name

              %(<span class="fmt-element-name">#{Support.esc(@i18n.get['clause'])}</span> )
            end
          end

          # fmt-preferred, fmt-admitted and fmt-deprecates from the
          # designations. The preferred term is in bold, a deprecated one
          # follows the label DEPRECATED.
          class Designations
            def initialize(i18n_class: nil)
              @i18n_class = i18n_class
            end

            def call(model)
              @i18n = Support.i18n(model, @i18n_class)
              Support.each_term(model) do |term, _section|
                prefer(term)
                admit(term)
                deprecate(term)
              end
              model
            end

            private

            def semx(kind, designation, bold)
              text = Support.esc(Support.designation_text(designation))
              text = "<strong>#{text}</strong>" if bold
              %(<semx element="#{kind}" source="#{Support.esc(designation.id)}">#{text}</semx>)
            end

            def prefer(term)
              items = Array(term.preferred)
              return if items.empty?

              term.fmt_preferred = items.map do |d|
                Support.build(term, :fmt_preferred, "<fmt-preferred><p>#{semx('preferred', d, true)}</p></fmt-preferred>")
              end
            end

            def admit(term)
              items = Array(term.admitted)
              return if items.empty? || !term.class.attributes.key?(:fmt_admitted)

              term.fmt_admitted = items.map do |d|
                Support.build(term, :fmt_admitted, "<fmt-admitted><p>#{semx('admitted', d, false)}</p></fmt-admitted>")
              end
            end

            def deprecate(term)
              items = Array(term.deprecates)
              return if items.empty? || !term.class.attributes.key?(:fmt_deprecates)

              label = Support.esc(@i18n.get["deprecated"])
              paras = items.map { |d| "<p>#{label}: #{semx('deprecates', d, false)}</p>" }.join
              term.fmt_deprecates = Support.build(term, :fmt_deprecates, "<fmt-deprecates>#{paras}</fmt-deprecates>")
            end
          end

          # fmt-definition: the definition text, led by the domain in angle
          # brackets when the term has one.
          class Definitions
            def call(model)
              Support.each_term(model) do |term, _section|
                definition = Array(term.definition).first or next
                paras = paragraphs(definition)
                next if paras.empty?

                domain = Array(term.domain).first
                if domain
                  dom = %(&lt;<semx element="domain" source="#{Support.esc(domain.id)}">#{Support.esc(Support.text_of(domain))}</semx>&gt; )
                  paras[0] = paras[0].sub(/(<p\b[^>]*>)/) { "#{$1}#{dom} " }
                end
                term.fmt_definition = Support.build(term, :fmt_definition, <<~XML)
                  <fmt-definition><semx element="definition" source="#{Support.esc(definition.id)}">#{paras.join}</semx></fmt-definition>
                XML
              end
              model
            end

            private

            def paragraphs(definition)
              verbal = Array(definition.verbal_definition).first if definition.respond_to?(:verbal_definition)
              Array((verbal || definition).p).map(&:to_xml)
            end
          end

          # Labels on term notes ("Note 1 to entry: ") and term examples
          # ("EXAMPLE", or "EXAMPLE 2" when there are several).
          class Annotations
            def initialize(i18n_class: nil)
              @i18n_class = i18n_class
            end

            def call(model)
              @i18n = Support.i18n(model, @i18n_class)
              Support.each_term(model) do |term, _section|
                notes(term)
                examples(term)
              end
              model
            end

            private

            def notes(term)
              return unless term.class.attributes.key?(:termnote)

              Array(term.termnote).each_with_index do |note, i|
                num = i + 1
                text = @i18n.get["termnote"].to_s.sub("%", %(<semx element="autonum" source="#{Support.esc(note.id)}">#{num}</semx>))
                note.autonum = num.to_s
                note.fmt_name = Support.build(note, :fmt_name,
                                              %(<fmt-name><span class="fmt-caption-label">#{text}</span><span class="fmt-label-delim">: </span></fmt-name>))
              end
            end

            def examples(term)
              return unless term.class.attributes.key?(:termexample)

              items = Array(term.termexample)
              items.each_with_index do |ex, i|
                num = items.size > 1 ? " <semx element=\"autonum\" source=\"#{Support.esc(ex.id)}\">#{i + 1}</semx>" : ""
                ex.autonum = items.size > 1 ? (i + 1).to_s : ""
                label = %(<span class="fmt-element-name">#{Support.esc(@i18n.get['example'])}</span>#{num})
                ex.fmt_name = Support.build(ex, :fmt_name, %(<fmt-name><span class="fmt-caption-label">#{label}</span></fmt-name>))
              end
            end
          end

          # fmt-termsource: "[SOURCE: citation, locality, modified — text]"
          # from the term's source elements. The locality is preceded by
          # its type name when locality_label is set.
          class Sources
            def initialize(locality_label: false, i18n_class: nil)
              @locality_label = locality_label
              @i18n_class = i18n_class
            end

            def call(model)
              @i18n = Support.i18n(model, @i18n_class)
              Support.each_term(model) do |term, _section|
                next unless term.class.attributes.key?(:fmt_termsource)

                sources = Array(term.source)
                next if sources.empty?

                term.fmt_termsource = [Support.build(term, :fmt_termsource, fmt(sources))]
              end
              model
            end

            private

            def fmt(sources)
              status = sources.first.status
              attr = status ? %( status="#{Support.esc(status)}") : ""
              body = sources.map { |s| one(s) }.join("; ")
              %(<fmt-termsource#{attr}>[#{Support.esc(@i18n.get['source'])}: #{body}]</fmt-termsource>)
            end

            def one(source)
              origin = Array(source.origin).first
              parts = []
              parts << Support.esc(origin.citeas) if origin
              loc = locality(origin)
              parts << loc unless loc.empty?
              text = parts.join(", ")
              text += ", #{Support.esc(@i18n.get[source.status.to_s] || source.status)}" if source.status
              mod = Array(source.modification).first
              text += " &#x2014; #{Support.esc(Support.text_of(mod))}" if mod && !Support.text_of(mod).empty?
              text
            end

            def locality(origin)
              Array(origin&.locality_stack).flat_map { |ls| Array(ls.locality) }.map do |l|
                from = l.reference_from.to_s
                @locality_label ? "#{Support.esc(l.type.to_s.capitalize)} #{Support.esc(from)}" : Support.esc(from)
              end.join(", ")
            end
          end
        end
      end
    end
  end
end
