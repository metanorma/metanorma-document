# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        # Body of sourcecode block, containing code text with embedded callout elements.
        # Uses map_all_content to preserve mixed content.
        class SourcecodeBody < Lutaml::Model::Serializable
          attribute :content, :string

          xml do
            element "body"
            map_all_content to: :content
          end
        end

        # Callout annotation in sourcecode, containing id, anchor, and paragraphs.
        class CalloutAnnotation < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :anchor, :string
          attribute :semx_id, :string
          attribute :original_id, :string
          attribute :p, Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                    collection: true

          xml do
            element "callout-annotation"
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_attribute "semx-id", to: :semx_id
            map_attribute "original-id", to: :original_id
            map_element "p", to: :p
          end
        end

        # Block containing computer code or comparable text.
        class SourcecodeBlock < Metanorma::Document::Components::Blocks::BasicBlockNoNotes
          # The caption of the block.
          attribute :name, Metanorma::Document::Components::Inline::NameWithIdElement

          # The block should be excluded from any automatic numbering of blocks of this class in the document.
          attribute :unnumbered, :boolean

          # Anchor attribute for cross-references
          attribute :anchor, :string

          # Define a subsequence for numbering of this block; e.g. if this block would be numbered
          # as 7, but it has a subsequence value of XYZ, this block, and all consecutive blocks
          # of the same class and with the same subsequence value, will be numbered consecutively
          # with the same number and in a subsequence: 7a, 7b, 7c etc.
          attribute :subsequence, :string

          # A file name associated with the source code (and which could be used to extract the source code
          # fragment to from the document, or to populate the source code fragment with from the external file,
          # in automated processing of the document).
          attribute :filename, :string

          # The computer language or other notational convention that the source code is expressed in.
          attribute :lang, :string

          # Whether callout markers are displayed
          attribute :markers, :string

          # The computer code or other such text presented in the block, as a single unformatted string. (The
          # string should be treated as pre-formatted text, with whitespace treated as significant.)
          attribute :content, :string

          # The source code body, containing code text with embedded callout references.
          attribute :body, SourcecodeBody

          # Zero or more cross-references; these are intended to be embedded within the `content` string, and
          # link to annotations.
          attribute :callouts,
                    Metanorma::Document::Components::ReferenceElements::ReferenceToIdElement, collection: true

          # Annotations to the source code; each annotation consists of zero or more paragraphs, and is intended
          # to be referenced by a callout within the source code.
          attribute :callout_annotations,
                    CalloutAnnotation, collection: true

          # Presentation-specific elements
          attribute :fmt_sourcecode, Metanorma::Document::Components::Inline::FmtSourcecodeElement

          # Presentation-specific: semx-id for round-trip fidelity
          attribute :semx_id, :string

          attribute :json_type, :string

          def json_type
            "sourcecode"
          end

          json do
            map "type", to: :json_type
            map "id", to: :id
            map "content", to: :content
            map "filename", to: :filename
            map "lang", to: :lang
          end

          xml do
            element "sourcecode"
            map_attribute "id", to: :id
            map_attribute "anchor", to: :anchor
            map_element "name", to: :name
            map_attribute "unnumbered", to: :unnumbered
            map_attribute "subsequence", to: :subsequence
            map_attribute "filename", to: :filename
            map_attribute "lang", to: :lang
            map_attribute "markers", to: :markers
            map_content to: :content
            map_element "body", to: :body
            map_element "callout", to: :callouts
            map_element "callout-annotation", to: :callout_annotations
            map_attribute "semx-id", to: :semx_id
            map_element "fmt-sourcecode", to: :fmt_sourcecode
          end
        end
      end
    end
  end
end
