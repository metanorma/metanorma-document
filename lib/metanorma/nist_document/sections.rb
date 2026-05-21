# frozen_string_literal: true

module Metanorma
  module NistDocument
    module Sections
      autoload :Errata, "#{__dir__}/sections/errata"
      autoload :ErrataClause, "#{__dir__}/sections/errata_clause"
      autoload :ErrataRow, "#{__dir__}/sections/errata_row"
      autoload :NistPreface, "#{__dir__}/sections/nist_preface"
    end
  end
end
