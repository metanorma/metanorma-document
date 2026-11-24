# frozen_string_literal: true

module Metanorma
  module Document
    # Presentation engine: turns a parsed Metanorma document into its
    # presentation model by applying a profile. Standalone.
    module Presentation
      autoload :Engine, "metanorma/document/presentation/engine"
      autoload :Profile, "metanorma/document/presentation/profile"
      autoload :ProfileError, "metanorma/document/presentation/profile_error"
      autoload :ProfileLoader, "metanorma/document/presentation/profile_loader"
      autoload :LayeredProfile, "metanorma/document/presentation/layered_profile"
      autoload :LabelData, "metanorma/document/presentation/label_data"
      autoload :Walk, "metanorma/document/presentation/walk"
      autoload :Behaviours, "metanorma/document/presentation/behaviours"
    end
  end
end
