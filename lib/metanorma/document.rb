# frozen_string_literal: true

require "nokogiri"

# See: https://metanorma.org
module Metanorma
  # Metanorma::Document is an abstraction between Nokogiri and Metanorma.
  # It deals with creating a class-based document to be used for handling
  # and converting Metanorma XML documents.
  module Document
    module_function

    def from_xml(file)
      file = Nokogiri::XML(file) unless file.is_a? Nokogiri::XML::Document

      Core::Node.from_ng(file)
    end

    alias from_ng from_xml
  end

  # Shorthand for Metanorma::Document.from_xml

  # rubocop:disable Naming/MethodName
  def self.Document(file)
    Document.from_xml(file)
  end
  # rubocop:enable Naming/MethodName
end

require_relative "document/core/node"
require_relative "document/core/top"
require_relative "document/core/core_ext"

require_relative "document/version"
