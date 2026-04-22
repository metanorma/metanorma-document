# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Keyword for a bibliographic item.
      class KeywordType < Lutaml::Model::Serializable
        attribute :content, :string
        attribute :vocab, Metanorma::Document::Components::DataTypes::LocalizedString
        attribute :taxon, :string, collection: true
        attribute :vocabid, Metanorma::Document::Relaton::VocabIdType,
                  collection: true

        xml do
          map_content to: :content
          map_element "vocab", to: :vocab
          map_element "taxon", to: :taxon
          map_element "vocabid", to: :vocabid
        end
      end
    end
  end
end
