# frozen_string_literal: true

module Metanorma
  module M3dDocument
    autoload :Metadata, "metanorma/m3d_document/metadata"
    autoload :Root, "metanorma/m3d_document/root"
  end
end

Metanorma::Registers::Setup.setup_m3d_register
