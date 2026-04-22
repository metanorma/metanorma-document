# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Type of bibliographic item.
      class BibItemType < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "bib-item-type"
          map_content to: :value
        end

        def self.values
          %w[article book booklet manual proceedings presentation thesis techReport
             standard unpublished map electronicResource audiovisual film video broadcast
             graphicWork music patent inBook inCollection inProceedings journal
             webResource website dataset archival software socialMedia alert message
             conversation misc]
        end
      end
    end
  end
end
