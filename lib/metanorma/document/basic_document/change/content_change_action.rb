# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # The actual content
  # changes that applies to the specified portion of textual content.
  # This is used both by the _ContentModify_ and _AttributeModify_ models
  # as their content are treated as pure text.
  class ContentChangeAction < Core::Node
  end
end; end; end
