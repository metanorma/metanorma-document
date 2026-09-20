# frozen_string_literal: true

module Metanorma
  module GbDocument
    autoload :Metadata, "metanorma/gb_document/metadata"
    autoload :Root, "metanorma/gb_document/root"
  end
end

Metanorma::Registers::Setup.setup_gb_register
