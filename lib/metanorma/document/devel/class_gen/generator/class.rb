# frozen_string_literal: true

module Metanorma; module Document; module Devel; module ClassGen; class Generator
  # Generates Ruby files for Classes
  class Class < Generator
    def generate_part
      module_block([::Class, @item.name, :"Core::Node"]) do
        # TODO
      end
    end
  end
end; end; end; end; end
