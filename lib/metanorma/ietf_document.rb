# frozen_string_literal: true

module Metanorma
  module IetfDocument
    autoload :Metadata, "metanorma/ietf_document/metadata"
    autoload :Root, "metanorma/ietf_document/root"
    autoload :Sections, "metanorma/ietf_document/sections"
  end
end

Metanorma::Registers::Setup.setup_ietf_register
