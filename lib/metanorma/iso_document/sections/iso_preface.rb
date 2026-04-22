# frozen_string_literal: true

module Metanorma
  module IsoDocument
    module Sections
      # Prefatory clauses appearing in an ISO/IEC document.
      class IsoPreface < Lutaml::Model::Serializable
        # Abstract.
        attribute :abstract, IsoAbstractSection

        # Foreword.
        attribute :foreword, IsoForewordSection

        # Introduction.
        attribute :introduction, IsoClauseSection

        # TOC and other special clauses in preface.
        attribute :clause, IsoClauseSection, collection: true

        # Acknowledgements section.
        attribute :acknowledgements, IsoClauseSection

        # Executive summary section.
        attribute :executivesummary, IsoClauseSection

        attribute :semx_id, :string
        attribute :displayorder, :integer

        xml do
          element "preface"
          map_element "abstract", to: :abstract
          map_element "foreword", to: :foreword
          map_element "introduction", to: :introduction
          map_element "clause", to: :clause
          map_element "acknowledgements", to: :acknowledgements
          map_element "executivesummary", to: :executivesummary
          map_attribute "semx-id", to: :semx_id
          map_attribute "displayorder", to: :displayorder
        end
      end
    end
  end
end
