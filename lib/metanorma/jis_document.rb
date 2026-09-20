# frozen_string_literal: true

module Metanorma
  module JisDocument
    autoload :Metadata, "metanorma/jis_document/metadata"
    autoload :Root, "metanorma/jis_document/root"
    autoload :Sections, "metanorma/jis_document/sections"
  end
end

Metanorma::Registers::Setup.setup_jis_register
