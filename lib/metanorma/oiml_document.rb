# frozen_string_literal: true

module Metanorma
  module OimlDocument
    autoload :Root, "metanorma/oiml_document/root"
  end
end

Metanorma::Registers::Setup.setup_oiml_register
