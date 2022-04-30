# frozen_string_literal: true

module Metanorma; module Document; module StandardDocument
  # Definition sections consist of one or more definition lists (`DefinitionCollection`),
  # are used to define symbols and
  # abbreviations used in the remainder of the document.
  #
  # They can also be used as glossaries, with simple definitions,
  # in contrast to the more elaborate definitions given in
  # terms sections.
  #
  # In addition to allowing prefatory text per section, each definition list
  # within each definition section can also be preceded by prefatory text.
  class DefinitionSection < Core::Node
  end
end; end; end
