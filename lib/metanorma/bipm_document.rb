# frozen_string_literal: true

require "metanorma/standard_document"

module Metanorma
  module BipmDocument
    autoload :Metadata, "metanorma/bipm_document/metadata"
    autoload :Root, "metanorma/bipm_document/root"
  end
end
