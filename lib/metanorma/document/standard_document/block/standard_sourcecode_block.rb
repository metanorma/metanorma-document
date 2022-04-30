# frozen_string_literal: true

require "basic_document/ancillaryblocks/sourcecode_block"

module Metanorma; module Document; module StandardDocument
  class StandardSourcecodeBlock < BasicDocument::SourcecodeBlock
    register_element do
      # Override the numbering of this block in numbering.
      attribute :number, String
    end
  end
end; end; end
