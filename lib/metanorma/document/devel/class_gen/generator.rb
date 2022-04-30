# frozen_string_literal: true

module Metanorma; module Document; module Devel; module ClassGen
  # Generates Ruby files based on their LutaML definition
  class Generator
    include Util

    def initialize(item, filename, modul)
      @item = item
      @filename = filename
      @module = modul
      @body = +""
      @requires = []
      @indent = 0
    end

    def generate
      generate_head
      generate_body

      requires = @requires.map do |i|
        i = "metanorma/document/#{i}"
        "require #{i.inspect}\n"
      end.join
      requires << "\n" unless requires.empty?
      @body = @body.gsub("{{REQUIRES}}", requires)

      filename = "#{__dir__}/../../#{@filename}.rb"
      FileUtils.mkdir_p(File.dirname(filename))
      File.write(filename, @body)
    end

    def generate_head
      line "# frozen_string_literal: true"
      line
      push "{{REQUIRES}}"
    end

    def push(*strs)
      @body << strs.join
    end

    def line(*strs)
      if @leading_line
        @leading_line = false
        push "\n"
      end

      if strs.empty?
        push "\n"
      else
        push " " * @indent, *strs, "\n"
      end
    end

    def leading_line
      @leading_line = true
    end

    def indent
      @indent += 2
      yield
      @indent -= 2
    end

    def block(*strs, ends: "end", &block)
      line(*strs)
      indent(&block)
      @leading_line = false
      line ends
    end

    # path: [[Module, :Metanorma], [Class, :Something, :SuperClass]]
    def module_block(*path, &block)
      begins = []
      ends = []

      path.each do |type, name, supername|
        type = type == ::Module ? "module " : "class "
        supername = supername ? " < #{supername}" : ""
        begins << "#{type}#{name}#{supername}"
        ends << "end"
      end

      block(begins.join("; "), ends: ends.join("; "), &block)
    end

    def comment(str)
      return if str.nil? || str.empty?

      str = str.strip

      str.split(/\r?\n/).each do |i|
        if i.empty?
          line "#"
        elsif i.length > 100
          accum = +""
          i.split.each do |word|
            if "#{accum} #{word}".length > 100
              line "# ", accum
              accum = +""
            end
            accum << " " unless accum.empty?
            accum << word
          end
          line "# ", accum unless accum.empty?
        else
          line "# ", i
        end
      end
    end

    def wrap_in_parent_module(&block)
      module_block([Module, :Metanorma], [Module, :Document], [Module, sc2pc(@module)], &block)
    end

    def generate_body
      wrap_in_parent_module do
        comment @item.definition if @item.definition
        generate_part
      end
    end
  end
end; end; end; end

require_relative "generator/enum"
require_relative "generator/class"
require_relative "generator/data_type"
