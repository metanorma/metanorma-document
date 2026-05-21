# frozen_string_literal: true

module Metanorma
  module IeeeDocument
    autoload :Metadata, "metanorma/ieee_document/metadata"
    autoload :Root, "metanorma/ieee_document/root"
    autoload :Sections, "metanorma/ieee_document/sections"
  end
end

Metanorma::Registers::Setup.setup_ieee_register
