# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # The international identifier scheme for the identifier of a person.
  class PersonalIdentifierType < Core::Node::Enum
    # The International Standard Name Identifier (ISNI).
    ISNI = new("Isni")

    # The Open Researcher and Contributor ID (ORCID).
    ORCID = new("Orcid")

    # A URI for the person.
    URI = new("Uri")
  end
end; end; end
