# frozen_string_literal: true

require "relaton/bib"

module Metanorma
  module Document
    module Relaton
      # Item in a controlled vocabulary.
      # relaton-bib's vocabid matches metanorma biblio.rng: +code+ and +term+
      # are child elements (this gem previously had +code+ as an attribute
      # and a recursive +term+).
      class VocabIdType < ::Relaton::Bib::Keyword::Vocabid
      end
    end
  end
end
