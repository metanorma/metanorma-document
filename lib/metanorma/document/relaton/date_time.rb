# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Type which allows date and time to be specified as either a Gregorian
  # date and time, as specified in <<iso8601>>, as text, or as both.
  class DateTime < Core::Node
    include Core::Node::Custom

    register_element do
      # Date and time, as specified in text.
      nodes :text, String

      # Gregorian date and time, as specified in <<iso8601>>. Can be used
      # as a canonical interpretation of the date and time given in `text`.
      nodes :content, BasicDocument::Iso8601DateTime
    end
  end
end; end; end
