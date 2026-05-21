# frozen_string_literal: true

module Metanorma
  module BsiDocument
    autoload :Metadata, "metanorma/bsi_document/metadata"
    autoload :Root, "metanorma/bsi_document/root"
    autoload :Sections, "metanorma/bsi_document/sections"
  end
end

Metanorma::Registers::Setup.setup_bsi_register
