# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Inline reference to a paragraph or paragraphs, appearing as annotation of source code.
  # The target of the callout is understood to be the location of the callout within the source code;
  # the extent of the target is not expressed overtly.
  class Callout < Core::Node
  end
end; end; end
