module Metanorma
  module Document
    module Components
      module Inline
        class FnElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :reference, :string
          attribute :hiddenref, :string
          attribute :target, :string
          attribute :semx_id, :string
          attribute :original_reference, :string
          attribute :p, "Metanorma::Document::Components::Paragraphs::ParagraphBlock",
                    collection: true
          attribute :fmt_fn_label, "Metanorma::Document::Components::Inline::FmtFnLabelElement"

          xml do
            element "fn"
            map_attribute "id", to: :id
            map_attribute "reference", to: :reference
            map_attribute "hiddenref", to: :hiddenref
            map_attribute "target", to: :target
            map_attribute "semx-id", to: :semx_id
            map_attribute "original-reference", to: :original_reference
            map_element "p", to: :p
            map_element "fmt-fn-label", to: :fmt_fn_label
          end
        end
      end
    end
  end
end
