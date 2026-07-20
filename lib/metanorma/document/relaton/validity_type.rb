# frozen_string_literal: true

require "relaton/bib"

module Metanorma
  module Document
    module Relaton
      # The time interval for which a bibliographic item
      # is determined valid, and the associated revision date.
      # Element names are identical; relaton-bib types the values :date_time
      # per biblio.rng ISO8601Date (this gem previously used :string).
      class ValidityType < ::Relaton::Bib::Validity
        # Compatibility readers: relaton-bib names them +begins+/+ends+.
        def validity_begins = begins

        def validity_ends = ends
      end
    end
  end
end
