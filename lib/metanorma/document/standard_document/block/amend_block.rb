# frozen_string_literal: true

require "metanorma/document/standard_document/block/standard_block_no_notes"

module Metanorma; module Document; module StandardDocument
  # Block expressing a machine-readable change in a document.
  class AmendBlock < StandardBlockNoNotes
    register_element do
      # The type of change described in this block.
      attribute :change, ChangeType

      # The location in the original document which has undergone the change described in this block.
      # Typically this is given as a clause.
      nodes :bib_locality, Relaton::BibItemLocality

      # The location within the bibLocality where the change applies to,
      # if bibLocality defines a container larger than the scope of the change.
      attribute :path, String

      # The end of the span within the bibLocality where the change applies to;
      # applicable to modify or delete.
      attribute :path_end, String

      # Optional caption of this block.
      attribute :name, String

      # Description of the change described in this block.
      nodes :description, BasicDocument::BasicBlock

      # Specification of how blocks of a given class should be autonumbered
      # within an AmendBlock newContent element.
      nodes :auto_number, AutoNumber

      # New content to be added to the document; applicable to add and modify.
      nodes :new_content, BasicDocument::BasicBlock
    end
  end
end; end; end
