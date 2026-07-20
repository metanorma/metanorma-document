# frozen_string_literal: true

module Metanorma
  module CsaDocument
    autoload :Root, "metanorma/csa_document/root"
  end
end

Metanorma::Registers::Setup.setup_csa_register
