# frozen_string_literal: true

require "basic_document/referenceelements/reference_to_id_element"

module Metanorma; module Document; module BasicDocument
  # Inline reference to a paragraph or paragraphs, appearing as annotation of source code.
  # The target of the callout is understood to be the location of the callout within the source code;
  # the extent of the target is not expressed overtly.
  class Callout < ReferenceToIdElement
  end
end; end; end
