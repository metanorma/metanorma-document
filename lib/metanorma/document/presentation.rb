# frozen_string_literal: true

module Metanorma
  module Document
    # Presentation engine: turns a parsed Metanorma document into its
    # presentation model by applying a profile. Standalone.
    module Presentation
      autoload :Engine, "metanorma/document/presentation/engine"
      autoload :Profile, "metanorma/document/presentation/profile"
    end
  end
end
