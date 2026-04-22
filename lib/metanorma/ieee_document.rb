# frozen_string_literal: true

require "metanorma/standard_document"
require "metanorma/iso_document"

module Metanorma
  module IeeeDocument
    autoload :Metadata, "metanorma/ieee_document/metadata"
    autoload :Root, "metanorma/ieee_document/root"
  end
end
