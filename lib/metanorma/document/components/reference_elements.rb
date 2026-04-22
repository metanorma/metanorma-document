# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module ReferenceElements
        autoload :Callout, "#{__dir__}/reference_elements/callout"
        autoload :Citation, "#{__dir__}/reference_elements/citation"
        autoload :Footnote, "#{__dir__}/reference_elements/footnote"
        autoload :IndexXrefElement,
                 "#{__dir__}/reference_elements/index_xref_element"
        autoload :ReferenceElement,
                 "#{__dir__}/reference_elements/reference_element"
        autoload :ReferenceFormat,
                 "#{__dir__}/reference_elements/reference_format"
        autoload :ReferenceToCitationElement,
                 "#{__dir__}/reference_elements/reference_to_citation_element"
        autoload :ReferenceToIdElement,
                 "#{__dir__}/reference_elements/reference_to_id_element"
        autoload :ReferenceToIdWithParagraphElement,
                 "#{__dir__}/reference_elements/reference_to_id_with_paragraph_element"
        autoload :ReferenceToLinkElement,
                 "#{__dir__}/reference_elements/reference_to_link_element"
      end
    end
  end
end
