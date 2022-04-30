# frozen_string_literal: true

require "basic_document/lists/list"

module Metanorma; module Document; module BasicDocument
  # Definition list, composed of definitions rather than list items.
  class DefinitionList < List
    register_element "dl" do
      # Definitions constituting the definition list.
      nodes :listitem, Definition
    end
  end
end; end; end
