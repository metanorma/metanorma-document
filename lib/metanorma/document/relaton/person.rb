# frozen_string_literal: true

require "metanorma/document/relaton/contributor"

module Metanorma; module Document; module Relaton
  # Person associated with a bibliographic item.
  class Person < Contributor
    register_element do
      # The name of the person.
      node :name, FullName

      # The affiliation of the person within an organization.
      nodes :affiliation, Affiliation

      # An identifier of the person according to an international identifier scheme.
      nodes :identifier, BasicObject # But actually: PersonalIdentifier

      # Contact information for the person, including URI, address, phone number, and email.
      nodes :contact, ContactMethod
    end
  end
end; end; end
