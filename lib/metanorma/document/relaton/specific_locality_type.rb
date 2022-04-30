# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Type of indicator of a location or extent within a bibliographic item.
  #
  # When the value `whole` or `title` is used, the corresponding `BibItemLocality`
  # attribute `identifier` should be empty.
  class SpecificLocalityType < Core::Node::Enum
    # Section.
    SECTION = new("section")

    # Clause.
    CLAUSE = new("clause")

    # Part.
    PART = new("part")

    # Paragraph.
    PARAGRAPH = new("paragraph")

    # Chapter.
    CHAPTER = new("chapter")

    # Page.
    PAGE = new("page")

    # The entirety of the document.
    WHOLE = new("whole")

    # Table.
    TABLE = new("table")

    # Annex or Appendix.
    ANNEX = new("annex")

    # Figure.
    FIGURE = new("figure")

    # Note.
    NOTE = new("note")

    # List (used for ordered lists in some standards documents).
    LIST = new("list")

    # Example.
    EXAMPLE = new("example")

    # Volume.
    VOLUME = new("volume")

    # Issue.
    ISSUE = new("issue")

    # Time (used for timestamps in audio and visual media).
    TIME = new("time")

    # Anchor (used for locations within web pages).
    ANCHOR = new("anchor")

    # Title (of a clause, figure, etc.)
    TITLE = new("title")

    # Line (of a block; dependent on printed form of document).
    LINE = new("line")

    # A free-form text string prefixed with locality information that is human-readable.
    LOCALITY_STRING = new("localityString")
  end
end; end; end
