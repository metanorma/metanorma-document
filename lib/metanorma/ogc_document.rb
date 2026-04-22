# frozen_string_literal: true

require "metanorma/standard_document"

module Metanorma
  module OgcDocument
    autoload :Metadata, "metanorma/ogc_document/metadata"
    autoload :Root, "metanorma/ogc_document/root"
  end
end
