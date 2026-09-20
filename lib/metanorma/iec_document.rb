# frozen_string_literal: true
require "metanorma/registers"

module Metanorma
  module IecDocument
    autoload :Root, "metanorma/iec_document/root"
  end
end

Metanorma::Registers::Setup.setup_iec_register
