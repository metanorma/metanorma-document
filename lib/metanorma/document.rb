# frozen_string_literal: true

require "nokogiri"

# See: https://metanorma.org
module Metanorma
  # Metanorma::Document is an abstraction between Nokogiri and Metanorma.
  # It deals with creating a class-based document to be used for handling
  # and converting Metanorma XML documents.
  #
  # It represents the documents as a single-linked tree structure, always
  # starting from a Metanorma::Document::Core::Top. This node responds to
  # a #root property that corresponds to the top XML element.
  #
  # It is intended to replace the current (previous?) system of Metanorma
  # programs communicating with one another with XML files, but also allow
  # for a seamless migration from/to those.
  #
  # Under the Core module there is a logic to make all this work. Under
  # the Devel module there are helper modules, to be used for development of
  # this system. Other modules represent the class systems for the
  # individual document types.
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
