# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # The time interval for which a bibliographic item
  # is determined valid, and the associated revision date.
  class ValidityType < Core::Node
    include Core::Node::Custom

    register_element do
      # The date and time when this bibliographic item becomes valid.
      nodes :validity_begins, BasicDocument::Iso8601DateTime

      # The date and time when this bibliographic item becomes invalid.
      nodes :validity_ends, BasicDocument::Iso8601DateTime

      # The date and time of issuance of the version of the document
      # for which this claim of validity is made, if applicable.
      nodes :revision, BasicDocument::Iso8601DateTime
    end
  end
end; end; end
