# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module ReferenceElements
        # Inline reference to a paragraph or paragraphs, appearing as annotation of source code.
        # The target of the callout is understood to be the location of the callout within the source code;
        # the extent of the target is not expressed overtly.
        class Callout < ReferenceToIdElement
          attribute :target_attr, :string
          attribute :type, :string
          attribute :text, :string, collection: true

          xml do
            element "callout"
            mixed_content
            map_attribute "target", to: :target_attr
            map_element "type", to: :type
            map_content to: :text
          end
        end
      end
    end
  end
end
