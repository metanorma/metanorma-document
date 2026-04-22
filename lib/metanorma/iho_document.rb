# frozen_string_literal: true

require "metanorma/standard_document"
require "metanorma/iso_document"

module Metanorma
  module IhoDocument
    autoload :Metadata, "metanorma/iho_document/metadata"
    autoload :Root, "metanorma/iho_document/root"
  end
end
