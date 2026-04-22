# frozen_string_literal: true

require "metanorma/iso_document"

module Metanorma
  module Collection
    autoload :Root, "metanorma/collection/root"
    autoload :Directive, "metanorma/collection/directive"
    autoload :Entry, "metanorma/collection/entry"
    autoload :DocContainer, "metanorma/collection/doc_container"
  end
end
