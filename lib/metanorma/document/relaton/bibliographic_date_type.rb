# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Indicates type of date within a bibliographic lifecycle.
      class BibliographicDateType < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "bibliographic-date-type"
          map_content to: :value
        end

        def self.values
          %w[published accessed created implemented obsoleted confirmed updated issued
             transmitted copied unchanged circulated adapted voteStarted voteEnded announced]
        end
      end
    end
  end
end
