# frozen_string_literal: true

module Metanorma; module Document; module Devel; module ClassGen; class Generator
  # Generates Ruby files for Classes
  class Class < Generator
    def generate_part
      sc = superklass
      module_block([::Class, @item.name, sc]) do
        if sc == :"Core::Node"
          line "include Core::Node::Custom"
          leading_line
        end

        if !@item.attributes || @item.attributes.empty?
          line "register_element"
        else
          block "register_element do" do
            @item.attributes.each do |i|
              comment i.definition
              type = if !i.cardinality || i.cardinality.max == "1"
                       "node"
                     else
                       "nodes"
                     end
              klass = locate_type(i.type, :child) || "BasicObject # But actually: #{i.type}"
              # This is a crude heuristic... but we may happen to be right in this case...
              type = "text" if type == "node" && i.type.to_sym == :PureTextElement
              type = "attribute" if type == "node" && ClassGen.basic_types.include?(i.type.to_sym)
              line "#{type} #{dc2sc(i.name).inspect}, #{klass}"
              leading_line
            end
          end
        end
      end
    end

    def locate_type(type, from)
      # Handle core classes
      case type.to_sym
      when :Boolean then return :TrueClass
      when :Int, :Integer then return :Integer
      when :Float then return :Float
      when :PureTextElement, :string, :String then return :String
      when :Any then return :Object
      end

      scmod = ClassGen.module_by_class[type.to_sym]

      unless scmod
        warn "!!!!!!!! Class #{@item.name} has a #{from} #{type} that is nowhere " \
             "to be found!"
        return nil
      end

      if scmod == @module
        type.to_sym
      else
        :"#{sc2pc scmod}::#{type}"
      end
    end

    def superklass
      a = ClassGen.associations.select { |i| i.owner_end_type == "inheritance" }
      a = a.select { |i| i.member_end == @item.name }.map(&:owner_end).uniq
      if a.length > 1
        warn "!!!!!!! Class #{@item.name} has multiple candidates for a superclass: " \
             "#{a.inspect}, taking the first"
      end
      a = a.first

      return :"Core::Node" unless a

      b = locate_type(a, :superclass)

      return :"Core::Node" unless b

      @requires << ClassGen.path_by_class[a.to_sym]

      b
    end
  end
end; end; end; end; end
