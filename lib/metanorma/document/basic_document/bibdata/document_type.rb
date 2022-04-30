# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Classifications of BasicDocuments.
  class DocumentType < Core::Node::Enum
    # Basicdoc only admits a single class of documents; more specific models of documents will necessarily
    # refine this classification.
    DOCUMENT = new("document")
  end
end; end; end
