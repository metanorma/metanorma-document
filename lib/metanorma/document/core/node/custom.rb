# frozen_string_literal: true

module Metanorma; module Document; module Core; class Node
  # Allows for custom classes.
  module Custom
    def self.included(klass)
      klass.include(Mixin) unless klass < Mixin
      klass.extend(ClassMethods)

      @member_fields = []
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
    @need_to_initialize = []

    singleton_class.attr_reader :handlers
    singleton_class.attr_accessor :need_to_initialize

    # @private
    def self.handler_for(name, xmlns = nil)
      Custom.handlers[[name, xmlns]] || Custom.handlers[[name, nil]] || Generic
    end

    # DSL for registering custom nodes
    module ClassMethods
      attr_reader :xml_name
      attr_accessor :member_fields, :descendants

      def register_element(name = nil, xmlns = nil, &block)
        @xml_name = [Array(name).first, xmlns]
        Array(name).each do |subname|
          Custom.handlers[[subname, xmlns]] = self
        end

        return unless block_given?

        @initializer = block
        if Custom.need_to_initialize.nil?
          initialize_custom_element
        else
          Custom.need_to_initialize << self
        end
      end

      def initialize_custom_element(deferred: false)
        self.member_fields = if deferred && superclass.is_a?(Custom)
                               superclass.member_fields.dup
                             else
                               []
                             end
        instance_exec(&@initializer)
      end

      def attribute(*args, **kwargs)
        member_fields << MemberField.new(self, :attribute, *args, **kwargs)
      end

      def node(*args, **kwargs)
        member_fields << MemberField.new(self, :node, *args, **kwargs)
      end

      def nodes(*args, **kwargs)
        member_fields << MemberField.new(self, :nodes, *args, **kwargs)
      end

      def text(*args, **kwargs)
        member_fields << MemberField.new(self, :text, *args, **kwargs)
      end

      def extended(other)
        other.member_fields = member_fields.dup || []
        self.descendants ||= []
        self.descendants << other
        super
      end
    end
  end
end; end; end; end

require_relative "custom/member_field"
