# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # FormattedString which optionally specifies its language and/or script.
  class LocalizedString < Core::Node
    include Core::Node::Custom

    register_element do
      # Language of string.
      nodes :language, Iso639Code

      # Script of string.
      nodes :script, Iso15924Code

      # The string being localized.
      node :content, LocalizedString

      # Variants of the string, with the same content, but in different language, script, or format.
      nodes :variant, LocalizedString
    end
  end
end; end; end
