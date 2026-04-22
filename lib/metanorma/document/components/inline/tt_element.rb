module Metanorma
  module Document
    module Components
      module Inline
        class TtElement < Lutaml::Model::Serializable
          attribute :text, :string, collection: true
          attribute :semx, "Metanorma::Document::Components::Inline::SemxElement",
                    collection: true

          xml do
            element "tt"
            mixed_content
            map_content to: :text
            map_element "semx", to: :semx
          end
        end
      end
    end
  end
end
