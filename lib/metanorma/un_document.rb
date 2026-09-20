# frozen_string_literal: true

module Metanorma
  module UnDocument
    autoload :Blocks, "metanorma/un_document/blocks"
    autoload :Metadata, "metanorma/un_document/metadata"
    autoload :Root, "metanorma/un_document/root"
    autoload :Sections, "metanorma/un_document/sections"
    autoload :UnTextElement, "metanorma/un_document/un_text_element"
  end
end

Metanorma::Registers::Setup.setup_un_register
