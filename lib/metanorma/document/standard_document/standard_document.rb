# frozen_string_literal: true

require "basic_document/basic_document"

module Metanorma; module Document; module StandardDocument
  # The _StandardDocument_ model is used to represent a standardization
  # document.
  #
  # Typically, a standardization document contains at least the
  # following data elements:
  #
  # * Metadata information;
  # * Clauses and subclauses;
  # * Bibliographies;
  # * Annexes if applicable.
  #
  # The exact component requirements of a standardization document
  # can differ widely from one standardization body to the next.
  # Specialization is necessary to adopt the `StandardDocument`
  # model for such standardization bodies.
  #
  # The _StandardDocument_ model extends the _BasicDocument_
  # modelling of the document by requiring specific types
  # of sections.
  class StandardDocument < BasicDocument::BasicDocument
  end
end; end; end
