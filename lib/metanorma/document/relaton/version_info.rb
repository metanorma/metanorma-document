# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # A version of the bibliographic item (within an edition). Can be used for drafts.
      class VersionInfo < Lutaml::Model::Serializable
        attribute :revision_date, :string
        attribute :draft, :string

        xml do
          element "version"
          map_element "revision-date", to: :revision_date
          map_element "draft", to: :draft
        end
      end
    end
  end
end
