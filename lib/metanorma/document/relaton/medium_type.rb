# frozen_string_literal: true

require "relaton/bib"

module Metanorma
  module Document
    module Relaton
      # Information about the medium and transmission of a bibliographic item.
      # relaton-bib's element grammar matches metanorma biblio.rng; this gem's
      # previous all-attribute mapping matched no valid metanorma document.
      class MediumType < ::Relaton::Bib::Medium
      end
    end
  end
end
