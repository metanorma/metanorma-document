# frozen_string_literal: true

module Metanorma; module Document; module Devel; module ClassGen; class Generator
  # Generates Ruby files for Enumerations
  class Enum < Generator
    def generate_part
      module_block([::Class, @item.name, :"Core::Node::Enum"]) do
        @item.attributes.each do |i|
          line unless i == @item.attributes.first
          comment i.definition if i.definition
          line "#{dc2cc i.name} = new(#{i.name.inspect})"
        end
      end
    end
  end
end; end; end; end; end
