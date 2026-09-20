# frozen_string_literal: true

module Metanorma
  module PlateauDocument
    autoload :Metadata, "metanorma/plateau_document/metadata"
    autoload :Root, "metanorma/plateau_document/root"
  end
end

Metanorma::Registers::Setup.setup_plateau_register
