# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Rendered counterpart of `<origin>` (a quote-attribution eref):
        # the normalised reference text. Identical grammar shape to
        # eref — the shared ErefContract declares and maps it.
        class FmtOriginElement < Lutaml::Model::Serializable
          include Inline::Vocabulary
          include RenderedDisplay

          ErefContract.declare_attributes(self)

          xml do
            element "fmt-origin"
            ErefContract.apply_mapping(self)
          end
        end
      end
    end
  end
end
