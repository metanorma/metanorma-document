# frozen_string_literal: true
require "metanorma/registers"

module Metanorma
  module CsaDocument
    autoload :Root, "metanorma/csa_document/root"
  end
end

Metanorma::Registers::Setup.setup_csa_register
