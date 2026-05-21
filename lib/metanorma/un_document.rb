# frozen_string_literal: true

module Metanorma
  module UnDocument
    autoload :Metadata, "metanorma/un_document/metadata"
    autoload :Root, "metanorma/un_document/root"
    autoload :Sections, "metanorma/un_document/sections"
  end
end

Metanorma::Registers::Setup.setup_un_register
