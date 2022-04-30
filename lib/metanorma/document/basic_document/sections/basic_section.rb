# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Group of blocks within text, which is a leaf node in the hierarchical organisation of text (does not
  # contain any sections of its own).
  class BasicSection < Core::Node
    include Core::Node::Custom

    register_element do
      # Title of the section.
      nodes :title, TextElement

      # Identifier for the section, to be used for cross-references within the document. (Citations of
      # references are modelled as cross-references to the corresponding bibliographical item in the
      # References section.)
      attribute :id, String

      # Language tags for the section, coded as ISO 639 codes.
      nodes :language, Iso639Code

      # Script tags for the section, coded as ISO 15924 codes.
      nodes :script, Iso15924Code

      # Blocks, containing the textual content of the section
      # (but excluding subsections, which are only present in Hierarchical Sections).
      nodes :blocks, BasicBlock

      # Any notes whose scope is the entire section, rather than a specific block.
      nodes :notes, NoteBlock
    end
  end
end; end; end
