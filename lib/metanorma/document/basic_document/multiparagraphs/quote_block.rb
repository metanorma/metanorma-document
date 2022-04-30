# frozen_string_literal: true

require "basic_document/multiparagraphs/paragraphs_block"

module Metanorma; module Document; module BasicDocument
  # Block quotation, containing extensive textual content originally authored outside of the current
  # document.
  class QuoteBlock < ParagraphsBlock
    register_element "quote" do
      # Bibliographic citation for the quotation.
      node :source, ReferenceToCitationElement, xml_tagname: "quote-source"

      # Author of the quotation. The `author` attribute of the quotation is redundant with the citation,
      # since it restates information about the author that should be recoverable from the citation itself.
      # It is included for convenience, in case processing the citation to extract the author is prohibitive
      # for rendering tools.
      node :author, Relaton::Contributor, xml_tagname: "quote-author"
    end
  end
end; end; end
