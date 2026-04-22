# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module MultiParagraph
      # Block quotation, containing extensive textual content originally authored outside of the current
      # document.
      class QuoteBlock < Metanorma::BasicDocument::MultiParagraph::ParagraphsBlock
        # Bibliographic citation for the quotation.
        attribute :source, Metanorma::BasicDocument::ReferenceElements::ReferenceToCitationElement

        # Author of the quotation. The `author` attribute of the quotation is redundant with the citation,
        # since it restates information about the author that should be recoverable from the citation itself.
        # It is included for convenience, in case processing the citation to extract the author is prohibitive
        # for rendering tools.
        attribute :author, Metanorma::Document::Relaton::Contributor

        xml do
          element "quote"
          map_element "source", to: :source
          map_element "author", to: :author
        end
      end
    end
  end
end
