# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # The MIME type for a formatted string.
  class StringFormat < Core::Node::Enum
    # Plain text.
    TEXT_PLAIN = new("text/plain")

    # HTML.
    TEXT_HTML = new("text/html")

    # DocBook.
    APPLICATION_DOCBOOK_XML = new("application/docbook+xml")

    # TEI (Text Encoding Initiative).
    APPLICATION_TEI_XML = new("application/tei+xml")

    # AsciiDoc.
    TEXT_X_ASCIIDOC = new("text/x-asciidoc")

    # Markdown.
    TEXT_MARKDOWN = new("text/markdown")

    # Metanorma.
    APPLICATION_X_METANORMA_XML = new("application/x-metanorma+xml")
  end
end; end; end
