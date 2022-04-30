# frozen_string_literal: true

module Metanorma; module Document; module Core; class Node; module Custom
  # Describes a member field of a given custom tag
  class MemberField
    def initialize(owner, type, name, klass, **kwargs)
      @owner = owner
      @type = type
      @name = name
      @klass = klass

      case type
      when :attribute
        @xml_attribute = kwargs.delete(:xml_attribute) || name.to_s
      when :node, :nodes
        @xml_tagname = kwargs.delete(:xml_tagname)
      end

      raise ArgumentError, "invalid kwargs: #{kwargs.keys}" unless kwargs.empty?
    end

    attr_accessor :owner, :type, :name, :klass, :xml_attribute, :xml_tagname
  end
end; end; end; end; end
