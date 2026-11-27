# frozen_string_literal: true

module Metanorma
  module Document
    module Sts
      module Transformer
        # Converts MN <quote> blocks (MultiParagraph::QuoteBlock) to
        # NISO STS <disp-quote> — the element mnconvert emits for the
        # same source. The quote's paragraphs render inside the
        # disp-quote; its unordered/ordered lists have no disp-quote
        # slot in the STS model and surface as sibling <list> elements
        # after it (BlockDispatcher#quote_trailing_lists).
        class QuoteTransformer < Base
          # The quote's source is <attrib specific-use="source"> (guidelines
          # 5.9), which the sts-ruby 0.6.15 DispQuote and Attrib models do
          # not map: they carry only <attribution> and no @specific-use.
          # These subclasses add the guideline's shape; the mapping order is
          # the serialization order, so <attrib> follows the paragraphs.
          class AttribWithSpecificUse < ::Sts::NisoSts::Attrib
            attribute :specific_use, :string

            xml do
              element "attrib"
              mixed_content

              map_attribute "id", to: :id
              map_attribute "specific-use", to: :specific_use

              map_content to: :content
              map_element "named-content", to: :named_content
              map_element "target", to: :target
            end
          end

          class DispQuoteWithAttrib < ::Sts::NisoSts::DispQuote
            attribute :attrib, AttribWithSpecificUse, collection: true

            xml do
              element "disp-quote"
              ordered

              map_attribute "id", to: :id
              map_attribute "content-type", to: :content_type
              map_attribute "originator", to: :originator
              map_attribute "specific-use", to: :specific_use

              map_element "label", to: :label
              map_element "p", to: :paragraphs
              map_element "attrib", to: :attrib
            end
          end

          def transform(source_quote)
            paragraphs = extract_paragraphs(source_quote)
            attrib = attrib_of(source_quote)
            return nil if paragraphs.empty? && attrib.nil?

            id = id_generator.id_for(source_quote)
            ModelBuilder.disp_quote(id: id, paragraph: paragraphs,
                                    attrib: attrib)
          end

          private

          # Guarded read: only classes that declare the attribute
          # answer it, so blocks lacking the slot yield [] instead of
          # raising.
          def extract_paragraphs(source_quote)
            return [] unless source_quote.class.attributes.key?(:paragraphs)

            Array(source_quote.paragraphs).map { |p| paragraph_transformer.transform(p) }
          end

          # The quote's attribution ("<quote><attribution><p>…")
          # renders as the source <attrib>'s mixed content text. The
          # AttributionElement itself is not text-walkable — its
          # paragraphs are.
          def attrib_of(source_quote)
            return nil unless source_quote.class.attributes.key?(:attribution)

            text = Array(source_quote.attribution).flat_map do |attr|
              next [] unless attr.class.attributes.key?(:p)

              Array(attr.p).map { |p| RenderedTextExtractor.text_of(p) }
            end.join(" ").strip
            return nil if text.empty?

            AttribWithSpecificUse.new(specific_use: "source", content: [text])
          end
        end
      end
    end
  end
end
