module Metanorma
  module Document
    module Components
      module Inline
        class FmtFootnoteContainerElement < Lutaml::Model::Serializable
          attribute :fmt_fn_body, FmtFnBodyElement, collection: true

          xml do
            element "fmt-footnote-container"
            map_element "fmt-fn-body", to: :fmt_fn_body
          end
        end
      end
    end
  end
end
