# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # A version of the bibliographic item (within an edition). Can be used for drafts.
      # Keeps its own mapping: relaton-bib 2.2.0.pre.alpha.1 Version folds
      # draft and revision-date into a synthesized content string — its
      # #revision_date and #draft readers return nil — while fixtures carry
      # structured version elements (iso-is: revision-date) that must stay
      # readable and round-trip as elements.
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
