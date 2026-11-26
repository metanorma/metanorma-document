# frozen_string_literal: true

require "metanorma/document"

module Metanorma
  module Document
    module Sts
      module Transformer
        # Read-only view over the flavor document model's typed root.
        # The reader class (the flavor's `Document::Root`) and the term
        # model classes carrying presentation autonums are PROFILE data:
        # the engine never references a flavor gem's classes itself.
        class SourceDocument
          attr_reader :typed_root

          # @param profile [Profile] supplies +reader_class+ and
          #   +term_classes+; see Profile.
          def self.parse(input, profile: nil)
            reader = (profile || Metanorma::Document::Sts::Profiles.default).reader_class
            unless reader
              raise ArgumentError,
                    "no STS reader class configured: the profile must set " \
                    "reader_class to the flavor document model's Root"
            end
            xml_string = input.respond_to?(:read) ? input.read : input.to_s
            typed = reader.from_xml(xml_string)
            new(typed, profile: profile)
          end

          # Reader entry point for the metanorma-core document_transformers
          # contract (+reader.from_xml(String) -> model+); an alias of {.parse}.
          def self.from_xml(input, profile: nil)
            parse(input, profile: profile)
          end

          def initialize(typed_root, profile: nil)
            @typed_root = typed_root
            @profile = profile
          end

          # The profile this document was parsed under; the engine default
          # when constructed directly from a typed root (the metanorma-core
          # driver hands over an already-parsed Root).
          def profile
            @profile || Metanorma::Document::Sts::Profiles.default
          end

          def bibdata
            typed_root.bibdata
          end

          def language
            return "en" unless bibdata

            langs = begin
              bibdata.language
            rescue StandardError
              nil
            end
            return "en" unless langs

            lang = langs.is_a?(Array) ? langs.first : langs
            return "en" unless lang

            val = lang.is_a?(String) ? lang : lang.value.to_s
            val.strip.match?(/\A[a-z]{2}(-[A-Z]{2})?\z/) ? val.strip : "en"
          end

          def docidentifier
            return nil unless bibdata

            ids = begin
              bibdata.doc_identifier
            rescue StandardError
              nil
            end
            return nil unless ids

            Array(ids).each do |id_obj|
              next if id_obj.type

              return text_of(id_obj)
            end
            text_of(Array(ids).first)
          end

          def text_of(obj)
            return obj.to_s if obj.is_a?(String)
            return "" unless obj

            val = begin
              obj.value
            rescue StandardError
              nil
            end || begin
              obj.content
            rescue StandardError
              nil
            end
            return "" unless val

            Array(val).map { |v| v.is_a?(String) ? v : text_of(v) }.join.strip
          end

          def title(type: nil)
            return nil unless bibdata

            titles = begin
              bibdata.titles
            rescue StandardError
              nil
            end
            return nil unless titles

            titles = Array(titles)
            t = titles.find do |x|
              type.nil? || begin
                x.type == type
              rescue StandardError
                false
              end
            end || titles.first
            text_of(t)
          end

          def formatted_title
            return title unless bibdata

            # The composed model #title can raise on documents whose front
            # lacks the title structure it expects; fall back to the
            # generic wrapper title rather than failing the transform.
            iso_title = begin
              bibdata.title
            rescue StandardError
              nil
            end
            return title unless iso_title

            main = abstract_title_value(iso_title.title_main)
            part_prefix = abstract_title_value(iso_title.title_part_prefix)
            part = abstract_title_value(iso_title.title_part)
            segments = [main]
            if part_prefix && !part_prefix.empty?
              segments << (part && !part.empty? ? "#{part_prefix}:#{part}" : part_prefix)
            elsif part && !part.empty?
              segments << part
            end
            segments.reject! { |s| s.nil? || s.empty? }
            return title if segments.empty?

            segments.join(" — ")
          end

          def abstract_title_value(abstract)
            return nil if abstract.nil?

            val = begin
              abstract.value
            rescue StandardError
              nil
            end
            val&.to_s&.strip
          end

          def copyright_year
            return nil unless bibdata

            cps = begin
              bibdata.copyright
            rescue StandardError
              nil
            end
            return nil unless cps

            cp = Array(cps).first
            return nil unless cp

            from = begin
              cp.from
            rescue StandardError
              nil
            end
            return text_of(from) unless from.nil?

            nil
          end

          def copyright_holder
            return nil unless bibdata

            cps = begin
              bibdata.copyright
            rescue StandardError
              nil
            end
            return nil unless cps

            cp = Array(cps).first
            return nil unless cp

            owner = begin
              cp.owner
            rescue StandardError
              nil
            end
            return nil unless owner

            org = begin
              Array(owner.organization).first
            rescue StandardError
              nil
            end
            return nil unless org

            begin
              text_of(org.name)
            rescue StandardError
              nil
            end
          end

          def publisher
            copyright_holder
          end

          def pub_date
            copyright_year
          end

          def foreword
            typed_root.preface&.foreword
          end

          def introduction
            typed_root.preface&.introduction
          end

          # Top-level sections of every kind — <clause>, <terms>,
          # <definitions>, <references> (normative references) — in
          # document order. The XML's physical order differs (references
          # trails the clauses); displayorder carries the intended one.
          SECTION_COLLECTIONS = %i[clause terms definitions references].freeze

          def sections
            secs = typed_root.sections
            return [] unless secs

            # displayorder (presentation XML) wins; without it the
            # element order of the source decides, never the grouping
            # by collection.
            SourceOrder.entries(secs, SECTION_COLLECTIONS).map(&:last)
              .each_with_index
              .sort_by { |s, i| [s.displayorder || Float::INFINITY, i] }
              .map(&:first)
          end

          def annexes
            Array(typed_root.annex)
          end

          def bibliography
            bib = typed_root.bibliography
            return [] unless bib

            Array(bib.references)
          end

          def front?
            !foreword.nil? || !introduction.nil?
          end

          def has_metadata?
            !docidentifier.nil?
          end

          def has_back?
            annexes.any? || bibliography.any?
          end

          def term_autonum_for(term_id)
            @term_autonum_cache ||= build_term_autonum_cache
            @term_autonum_cache[term_id]
          end

          private

          def build_term_autonum_cache
            cache = {}
            term_classes = profile.term_classes
            return cache if term_classes.nil? || term_classes.empty?

            walk_for_terms(typed_root) do |term|
              next unless term_classes.any? { |klass| term.is_a?(klass) }

              autonum = extract_term_autonum(term)
              next unless autonum && !autonum.empty?

              cache[term.id] = autonum if term.id
              anchor = term.anchor
              cache[anchor] = autonum if anchor && !cache.key?(anchor)
            end
            cache
          end

          def walk_for_terms(node, seen = {}.compare_by_identity, &blk)
            return unless node.is_a?(Object) && !node.is_a?(String)
            return if seen.key?(node)

            seen[node] = true
            yield(node)
            # Only lutaml-model serializable nodes carry mapped child
            # collections; the public attributes API answers for them.
            return unless node.is_a?(Lutaml::Model::Serializable)

            node.class.attributes.each_key do |name|
              val = begin
                node.public_send(name)
              rescue StandardError
                next
              end
              next if val.nil?

              Array(val).each { |v| walk_for_terms(v, seen, &blk) if v.is_a?(Object) && !v.is_a?(String) && !v.is_a?(Array) }
            end
          end

          def extract_term_autonum(term)
            label_arr = Array(term.fmt_xref_label)
            label = label_arr.first
            return nil unless label
            return nil unless label.respond_to?(:each_mixed_content)

            parts = []
            label.each_mixed_content do |n|
              if n.is_a?(String) && !n.strip.empty?
                parts << n.strip
              else
                cn = n.class.name.split("::").last
                txt = semx_text(n) if cn == "SemxElement"
                txt = span_text(n) if cn == "SpanElement"
                parts << txt if txt && !txt.empty?
              end
            end
            parts.join.strip
          end

          def semx_text(semx)
            return "" unless semx.respond_to?(:each_mixed_content)

            parts = []
            semx.each_mixed_content { |n| parts << n if n.is_a?(String) }
            parts.join
          end

          def span_text(span)
            return "" unless span.respond_to?(:each_mixed_content)

            parts = []
            span.each_mixed_content { |n| parts << n if n.is_a?(String) }
            parts.join
          end
        end
      end
    end
  end
end
