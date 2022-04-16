# frozen_string_literal: true

module Metanorma; module Document; module Core; class Node
  # Allows for custom classes.
  module Custom
    def self.included(klass)
      klass.include(Mixin) unless klass < Mixin
      klass.extend(ClassMethods)
    end

    # Registration DSL:
    # This DSL allows you to create a subclass, that will automatically
    # register and Metanorma::Document will return a correct
    # class.
    #
    # To do so, you just need to do:
    #
    # class MyElement < Metanorma::Document::Core::Node
    #   include Metanorma::Document::Core::Node::Custom
    #   register_element "my-element"
    # end

    @handlers = {}

    singleton_class.attr_reader :handlers

    # @private
    def self.handler_for(name, xmlns = nil)
      Custom.handlers[[name, xmlns]] || Custom.handlers[[name, nil]] || Nodes::Generic
    end

    # DSL for registering custom nodes
    module ClassMethods
      attr_reader :xml_name

      def register_element(name, xmlns = nil)
        Custom.handlers[[name, xmlns]] = self
        @xml_name = [name, xmlns]
      end
    end
  end
end; end; end; end
