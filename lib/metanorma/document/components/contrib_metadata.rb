# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module ContribMetadata
        autoload :ContributionElementMetadata,
                 "#{__dir__}/contrib_metadata/contribution_element_metadata"
        autoload :Hash, "#{__dir__}/contrib_metadata/hash"
        autoload :IntegrityValue, "#{__dir__}/contrib_metadata/integrity_value"
        autoload :Iso10118Oid, "#{__dir__}/contrib_metadata/iso10118_oid"
        autoload :Iso14888Oid, "#{__dir__}/contrib_metadata/iso14888_oid"
        autoload :Signature, "#{__dir__}/contrib_metadata/signature"
      end
    end
  end
end
