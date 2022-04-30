# frozen_string_literal: true

require "metanorma/document/relaton/organization"

module Metanorma; module Document; module IsoDocument
  # Editorial groups associated with the production of an ISO/IEC document.
  class IsoProjectGroup < Relaton::Organization
    register_element do
      # Technical committees.
      nodes :technical_committee, IsoSubGroup

      # Subcommittees.
      nodes :subcommittee, IsoSubGroup

      # Workgroups.
      nodes :workgroup, IsoSubGroup

      # Secretariat.
      attribute :secretariat, String
    end
  end
end; end; end
