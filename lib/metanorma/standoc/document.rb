# frozen_string_literal: true

require "nokogiri"

module Metanorma; module Standoc
  module Document
    module_function

    def from_xml(file)
      file = Nokogiri::XML(file) unless file.is_a? Nokogiri::XML::Document

      Node.from_ng(file)
    end

    alias from_ng from_xml
  end

  # Shorthand for Metanorma::Standoc::Document.from_xml
  def self.Document(file)
    Document.from_xml(file)
  end
end; end

require_relative "document/node"
require_relative "document/top"
require_relative "document/nodes"
require_relative "document/core_ext"

require_relative "document/version"
