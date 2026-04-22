module Metanorma
  module Document
    module Components
      module Inline
        class SupElement < Lutaml::Model::Serializable
          attribute :text, :string, collection: true
          attribute :semx, "Metanorma::Document::Components::Inline::SemxElement",
                    collection: true
          attribute :span, "Metanorma::Document::Components::Inline::SpanElement",
                    collection: true
          attribute :fmt_xref, "Metanorma::Document::Components::Inline::FmtXrefElement",
                    collection: true

          xml do
            element "sup"
            mixed_content
            map_content to: :text
            map_element "semx", to: :semx
            map_element "span", to: :span
            map_element "fmt-xref", to: :fmt_xref
          end
        end
      end
    end
  end
end
