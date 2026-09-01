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
    autoload :Elements, "metanorma/document/elements"
    autoload :ModelAccess, "metanorma/document/model_access"
    autoload :NativeModels, "metanorma/document/native_models"
    autoload :PlainText, "metanorma/document/plain_text"
    autoload :Relaton, "metanorma/document/relaton"
    autoload :Root, "metanorma/document/root"
    autoload :Version, "metanorma/document/version"
    autoload :VERSION, "metanorma/document/version"
    autoload :CLI, "metanorma/document/cli"

    module_function

    def from_file(file)
      # For now, we cannot parse arbitrary XML into Lutaml models without knowing
      # the target class. This will be addressed in a future refactoring.
      # BasicDocument does not have XML root mapping and cannot be used to parse
      # documents directly. Use a flavor document model for specific flavors.
      raise NotImplementedError,
            "BasicDocument cannot parse XML directly. " \
            "Use a flavor document model (e.g. Metanorma::Standoc::Document::Root " \
            "from metanorma-standoc), or implement a custom parser."
    end
  end

  autoload :BasicDocument, "#{__dir__}/basic_document"
  autoload :Collection, "metanorma/collection"
  autoload :Html, "metanorma/html"
  autoload :Mirror, "metanorma/mirror"
  # Mko: the format lives in the metanorma-mko gem; Metanorma::Mko is
  # REOPENED by the model side (document/mko.rb) with the projection
  # walk and export entry points.
  autoload :Mko, "metanorma/document/mko"
end
