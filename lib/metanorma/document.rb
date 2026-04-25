# frozen_string_literal: true

require "lutaml/model"

# See: https://metanorma.org
module Metanorma
  # Metanorma::Document is a class-based document model for Metanorma.
  # It deals with creating a class-based document to be used for handling
  # and converting Metanorma XML documents.
  #
  # It uses Lutaml::Model::Serializable as the base for all document elements,
  # providing XML serialization/deserialization via a declarative DSL.
  #
  # It is intended to replace the current (previous?) system of Metanorma
  # programs communicating with one another with XML files, but also allow
  # for a seamless migration from/to those.
  module Document
    autoload :Components, "metanorma/document/components"
    autoload :DataTypes, "metanorma/document/data_types"
    autoload :Relaton, "metanorma/document/relaton"
    autoload :Root, "metanorma/document/root"
    autoload :Version, "metanorma/document/version"

    module_function

    def from_file(file)
      # For now, we cannot parse arbitrary XML into Lutaml models without knowing
      # the target class. This will be addressed in a future refactoring.
      # BasicDocument does not have XML root mapping and cannot be used to parse
      # documents directly. Use StandardDocument or IsoDocument for specific flavors.
      raise NotImplementedError,
            "BasicDocument cannot parse XML directly. " \
            "Use StandardDocument or IsoDocument for specific document flavors, " \
            "or implement a custom parser that determines the appropriate document class."
    end
  end

  autoload :BasicDocument, "#{__dir__}/basic_document"
  autoload :StandardDocument, "metanorma/standard_document"
  autoload :IsoDocument, "metanorma/iso_document"
  autoload :IecDocument, "metanorma/iec_document"
  autoload :IeeeDocument, "metanorma/ieee_document"
  autoload :IhoDocument, "metanorma/iho_document"
  autoload :OimlDocument, "metanorma/oiml_document"
  autoload :IetfDocument, "metanorma/ietf_document"
  autoload :CcDocument, "metanorma/cc_document"
  autoload :BipmDocument, "metanorma/bipm_document"
  autoload :ItuDocument, "metanorma/itu_document"
  autoload :OgcDocument, "metanorma/ogc_document"
  autoload :RiboseDocument, "metanorma/ribose_document"
  autoload :IetfDocument, "metanorma/ietf_document"
  autoload :Collection, "metanorma/collection"
  autoload :Html, "metanorma/html"
end
