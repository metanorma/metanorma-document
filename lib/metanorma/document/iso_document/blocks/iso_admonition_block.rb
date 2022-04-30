# frozen_string_literal: true

require "metanorma/document/basic_document/multiparagraphs/admonition_block"

module Metanorma; module Document; module IsoDocument
  class IsoAdmonitionBlock < BasicDocument::AdmonitionBlock
    register_element do
      # Types of admonition specific to ISO/IEC.
      attribute :type, IsoAdmonitionType
    end
  end
end; end; end
