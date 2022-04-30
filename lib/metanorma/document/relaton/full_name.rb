# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # The name of a person.
  class FullName < Core::Node
    include Core::Node::Custom

    register_element do
      # A prefixed addition to the name of the person, such as "Dr".
      nodes :prefix, BasicDocument::LocalizedString

      # A forename or given name of the person. Includes middle names.
      nodes :forename, BasicDocument::LocalizedString

      # The initials of the person: can be used instead of forenames.
      nodes :initials, BasicDocument::LocalizedString

      # The surname, family name, or equivalent of the person.
      node :surname, BasicDocument::LocalizedString

      # A suffixed addition to the name of the person, such as "Jr".
      nodes :addition, BasicDocument::LocalizedString

      # A preformatted version of the name of the person, not broken down into its component parts.
      nodes :complete_name, BasicDocument::LocalizedString

      # An additional note about the name of the person.
      nodes :note, BasicDocument::LocalizedString

      # A variant name of the person.
      nodes :variant, VariantFullName
    end
  end
end; end; end
