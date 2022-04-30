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

      scmod = ClassGen.module_by_class[a.to_sym]

      unless scmod
        warn "!!!!!!!! Class #{@item.name} has a superclass #{a} that is nowhere " \
             "to be found!"
        return :"Core::Node"
      end

      @requires << ClassGen.path_by_class[a.to_sym]

      if scmod == @module
        a.to_sym
      else
        :"#{sc2pc scmod}::#{a}"
      end
    end
  end
end; end; end; end; end
