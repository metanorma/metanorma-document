# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Type of the relationship between a main document (described in `BibliographicItem`)
      # and a target document.
      class DocumentRelationType < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          element "document-relation-type"
          map_content to: :value
        end

        def self.values
          %w[includes includedIn hasPart partOf merges mergedInto splits splitInto
             instanceOf hasInstance exemplarOf hasExemplar manifestationOf hasManifestation
             reproductionOf hasReproduction reprintOf hasReprint expressionOf hasExpression
             translatedFrom hasTranslation arrangementOf hasArrangement abridgementOf
             hasAbridgement annotationOf hasAnnotation draftOf hasDraft editionOf
             hasEdition updates updatedBy derivedFrom derives describes describedBy
             catalogues cataloguedBy hasSuccessor successorOf adaptedFrom hasAdaptation
             adoptedFrom adoptedAs reviewOf hasReview commentaryOf hasCommentary
             identical nonequivalent equivalent related complements complementOf
             obsoletes obsoletedBy cites isCitedIn]
        end
      end
    end
  end
end
