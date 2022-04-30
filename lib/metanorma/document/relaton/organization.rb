# frozen_string_literal: true

require "relaton/contributor"

module Metanorma; module Document; module Relaton
  # Organization associated with a bibliographic item.
  class Organization < Contributor
    register_element do
      # The name of the organization.
      nodes :name, BasicDocument::LocalizedString

      # A variant name of the organization.
      nodes :variant, VariantOrgName

      # The subdivision of the organization directly involved with the production of the bibliographic item.
      nodes :subdivision, BasicDocument::LocalizedString

      # A variant name of the subdivision.
      nodes :variant_subdivision, VariantOrgName

      # Abbreviation under which the organization is known.
      nodes :abbreviation, BasicDocument::LocalizedString

      # A URI with information about the organization.
      nodes :uri, TypedUri

      # An identifier of the organization according to an international identifier scheme.
      nodes :identifier, OrgIdentifier

      # Contact information for the organization, including address, phone number, and email.
      nodes :contact, ContactMethod
    end
  end
end; end; end
