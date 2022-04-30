# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # A paragraph which may also contain footnotes.
  # While most paragraphs in a document can contain footnotes, the distinction is necessary, as
  # footnotes are not appropriate for all instances of paragraph content in a document (e.g. sourcecode
  # annotations).
  class ParagraphWithFootnote < Core::Node
  end
end; end; end
