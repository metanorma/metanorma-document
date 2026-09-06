# frozen_string_literal: true

module Metanorma
  module Html
    # Renderer concerns. Lives in its own file so any consumer (the
    # model layer's PlainText extractor includes TextExtraction) can
    # resolve it through the html.rb autoload — independent of whether
    # BaseRenderer has loaded yet.
    module Concerns
      autoload :MetadataExtraction,
               "metanorma/html/concerns/metadata_extraction"
      autoload :PresentationValidation,
               "metanorma/html/concerns/presentation_validation"
      autoload :SvgProcessing, "metanorma/html/concerns/svg_processing"
      autoload :TextExtraction, "metanorma/html/concerns/text_extraction"
      autoload :TocRegistry, "metanorma/html/concerns/toc_registry"
    end
  end
end
