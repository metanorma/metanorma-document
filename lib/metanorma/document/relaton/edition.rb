# frozen_string_literal: true

require "relaton/bib"

module Metanorma
  module Document
    module Relaton
      class Edition < ::Relaton::Bib::Edition
        attribute :language, :string

        xml do
          root "edition"
          map_attribute "language", to: :language, render_empty: true
        end
      end
    end
  end
end
