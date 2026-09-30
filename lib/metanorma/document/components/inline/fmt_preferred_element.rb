# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        class FmtPreferredElement < Lutaml::Model::Serializable
          include RenderedDisplay

          attribute :p, "Metanorma::Document::Components::Paragraphs::ParagraphBlock",
                    collection: true
          attribute :semx, "Metanorma::Document::Components::Inline::SemxElement",
                    collection: true

          xml do
            element "fmt-preferred"
            map_element "p", to: :p
            map_element "semx", to: :semx
          end
        end
      end
    end
  end
end
