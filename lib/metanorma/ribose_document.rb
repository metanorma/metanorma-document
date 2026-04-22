# frozen_string_literal: true

require "metanorma/standard_document"

module Metanorma
  module RiboseDocument
    autoload :Metadata, "metanorma/ribose_document/metadata"
    autoload :Root, "metanorma/ribose_document/root"
  end
end
