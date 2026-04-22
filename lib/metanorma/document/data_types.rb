# frozen_string_literal: true

# Redirect to Components::DataTypes for backwards compatibility
require "metanorma/document/components/data_types"

module Metanorma
  module Document
    # @deprecated Use {Components::DataTypes} instead
    DataTypes = Metanorma::Document::Components::DataTypes
  end
end
