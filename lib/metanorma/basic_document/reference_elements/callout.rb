# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module ReferenceElements
      # Inline reference to a paragraph or paragraphs, appearing as annotation of source code.
      # The target of the callout is understood to be the location of the callout within the source code;
      # the extent of the target is not expressed overtly.
      class Callout < Metanorma::BasicDocument::ReferenceElements::ReferenceToIdElement
        attribute :type, BasicObject
        attribute :text, Metanorma::BasicDocument::TextElements::TextElement

        xml do
          element "callout"
          map_element "type", to: :type
          map_element "text", to: :text
        end
      end
    end
  end
end
