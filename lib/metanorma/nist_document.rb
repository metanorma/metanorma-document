# frozen_string_literal: true

module Metanorma
  module NistDocument
    autoload :Metadata, "metanorma/nist_document/metadata"
    autoload :Root, "metanorma/nist_document/root"
    autoload :Sections, "metanorma/nist_document/sections"
  end
end

Metanorma::Registers::Setup.setup_nist_register
