# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # Rendered counterpart of `<eref>`: the bibliographic reference
        # left as a citation in Presentation XML (no URL or bib entry
        # to link to). Identical grammar shape to eref — the shared
        # ErefContract declares and maps it.
        class FmtErefElement < Lutaml::Model::Serializable
          include Inline::Vocabulary
          include RenderedDisplay

          ErefContract.declare_attributes(self)

          xml do
            element "fmt-eref"
            ErefContract.apply_mapping(self)
          end
        end
      end
    end
  end
end
