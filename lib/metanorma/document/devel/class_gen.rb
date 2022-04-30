# frozen_string_literal: true

require "fileutils"
require "lutaml/uml"

require_relative "class_gen/util"
require_relative "class_gen/generator"

module Metanorma; module Document; module Devel
  # Generates the class structure based on their LutaML
  # descriptions.
  #
  # This is called by bin/class_gen
  #
  # It is highly recommended to run this on a Linux system.
  # Other systems may (or may not) yield unexpected results.
  module ClassGen
    module_function

    extend FileUtils
    extend Util

    def call
      set_tmp_path "/tmp/mndoc-repos"
      set_write_path "#{__dir__}/../"

      # Warning: repos need to be presented in a correct order, the most
      # basic one first.
      add_repo :BasicDocument, "https://github.com/metanorma/basicdoc-models",
               "models", branch: "master"
      add_repo :Relaton, "https://github.com/relaton/relaton-models",
               "models", branch: "main"
      add_repo :StandardDocument, "https://github.com/SirMartin1979/metanorma-model-standoc",
               "models/standard_document", branch: "rename-references"
      add_repo :IsoDocument, "https://github.com/SirMartin1979/metanorma-model-iso",
               "models/iso_document", branch: "rename-references"

      fetch_repos
      create_combined_repo

      parse_combined_repo
    end

    def set_write_path(path)
      @write_path = path
    end

    def set_tmp_path(path)
      @tmp_path = path
    end

    def add_repo(name, url, dir, branch: "master")
      @repos ||= {}

      @repos[name] = [url, dir, branch]
    end

    def fetch_repos
      mkdir_p(root = "#{@tmp_path}/repos")
      @repos.each do |name, (url, _dir, branch)|
        next if File.directory? "#{root}/#{name}"

        Dir.chdir(root) do
          system "git clone -b #{branch} #{url} #{name}"
        end
      end
    end

    def create_combined_repo
      root = "#{@tmp_path}/repos"
      rm_rf(combined = "#{@tmp_path}/combined")
      mkdir_p("#{combined}/views")
      mkdir_p("#{combined}/models")

      @repos.each do |name, (_url, dir)|
        Dir["#{root}/#{name}/#{dir}/**/*.lutaml"].each do |f|
          base_f = f["#{root}/#{name}/#{dir}/".length..-1]
          fn = "#{combined}/models/#{pc2sc name}/#{base_f}"
          mkdir_p(File.dirname(fn))
          ln_s(f, fn)
        end
        Dir["#{root}/#{name}/views/*"].each do |f|
          ln_s(f, "#{combined}/views/#{name}_#{File.basename(f)}")
        end

        if dir == "models"
          # Let's adjust the pc2sc name to the includes in views...

          Dir["#{root}/#{name}/views/**/*.lutaml"].each do |i|
            f = File.read(i)
            f = f.gsub(%r{(include \.\./models/)}, "\\1#{pc2sc name}/")
            File.write(i, f) unless f =~ %r{#{pc2sc name}/#{pc2sc name}}
          end
        else
          # This repo contains classes that extend the existing repos...
          # Some may be new files, some may already exist under conflicting names?

          dirs = Dir["#{root}/#{name}/models/*"]
          dirs -= ["#{root}/#{name}/#{dir}"]

          dirs.each do |d|
            base_d = File.basename(d)
            Dir["#{d}/**/*.lutaml"].each do |f|
              base_f = f[d.length - base_d.length..-1]
              existing_classes = Dir["#{combined}/models/#{base_d}/**/*.lutaml"].to_h do |i|
                [File.basename(i), i]
              end
              class_name = File.basename(f)
              if File.exist? "#{combined}/models/#{base_f}"
                # All ok!
              elsif existing_classes.key? class_name
                new_f = "#{combined}/models/#{base_f}"
                warn "!! (#{name}) Different path: models/#{base_f} => " \
                     "#{existing_classes[class_name][combined.length + 1..-1]}"
                mkdir_p(File.dirname(new_f))
                ln_s existing_classes[class_name], new_f
              else
                warn "!!!!!! File #{base_f} doesn't exist in a base repo!"
              end
            end
          end
        end
      end

      # Ensure all entities are referenced.
      includes = Dir["#{combined}/views/*.lutaml"].map do |i|
        File.read(i).scan %r{include ../(.*)$}
      end
      includes = includes.flatten.map { |i| i.gsub("\r", "") }.uniq

      files = Dir["#{combined}/models/**/*.lutaml"]

      files = files.map { |i| i[combined.length + 1..-1] }

      missing = files - includes
      warn "!!! Models unreferenced by views: #{missing.inspect}" unless missing.empty?

      missing = includes - files
      warn "!!! Models referenced but missing: #{missing.inspect}" unless missing.empty?
    end

    singleton_class.attr_reader :path_by_class, :module_by_class, :associations, :basic_types

    def parse_combined_repo
      @associations = []
      classes = []
      enums = []
      data_types = []
      primitives = []
      @path_by_class = {}
      @module_by_class = {}

      Dir["#{@tmp_path}/combined/views/**/*.lutaml"].each do |file|
        warn "... working on #{file} ..."
        parsed = Lutaml::Uml::Parsers::Dsl.parse(File.open(file))

        @associations += parsed.associations || []
        classes += parsed.classes || []
        enums += parsed.enums || []
        data_types += parsed.data_types || []
        primitives += parsed.primitives || []
      end

      # Deduplicate things
      classes = classes.to_h { |i| [i.name, i] }.values
      enums = enums.to_h { |i| [i.name, i] }.values
      data_types = data_types.to_h { |i| [i.name, i] }.values
      primitives = primitives.to_h { |i| [i.name, i] }.values

      @basic_types = [enums, data_types, primitives].flatten.map(&:name).map(&:to_sym)
      @basic_types += %i[Boolean Int Integer Float]

      combined = "#{@tmp_path}/combined"

      # Build helper hashes
      Dir["#{combined}/models/**/*.lutaml"].map do |i|
        %r{/models/(?<source>.*?)/} =~ i
        klass = File.basename(i, ".lutaml").to_sym
        path = i["#{combined}/models/".length..-1]

        if @module_by_class[klass]
          warn "!!!!!!! duplicate #{klass} : in #{@module_by_class[klass]} and #{source}"

          # !!!!!!! duplicate BibliographicItem : in basic_document and relaton
          # !!!!!!! duplicate Citation : in basic_document and relaton
          # !!!!!!! duplicate FormattedString : in basic_document and relaton
          # !!!!!!! duplicate Iso15924Code : in basic_document and relaton
          # !!!!!!! duplicate Iso639Code : in basic_document and relaton
          # !!!!!!! duplicate Iso8601DateTime : in basic_document and relaton
          # !!!!!!! duplicate LocalizedString : in basic_document and relaton
          # !!!!!!! duplicate StringFormat : in basic_document and relaton
          # !!!!!!! duplicate Uri : in basic_document and relaton

          # Let's use BasicDocument's definitions for for now;
          # perhaps Relaton should extend BasicDocument, or another common parent
          # should be created?
          next
        end

        formatted_path = path.split(".").first.split("/")
        formatted_path[-1] = pc2sc(formatted_path[-1])
        formatted_path = formatted_path.join("/")

        @path_by_class[klass] = formatted_path
        @module_by_class[klass] = source
      end

      done = []

      {
        Generator::Enum => enums,
        Generator::Class => classes,
        Generator::DataType => data_types
      }.each do |generator, data|
        data.each do |i|
          name = i.name.to_sym

          unless @module_by_class[name]
            warn "!!!!!!!! #{generator} of #{name} has no equivalent file!"
            next
          end

          if done.include? @path_by_class[name]
            warn "!!!!!!!! #{generator} of #{name} was already processed!"
          else
            done << @path_by_class[name]
          end

          generator.new(
            i,
            @path_by_class[name],
            @module_by_class[name]
          ).generate
        end
      end

      # Generate the require files
      @repos.each do |name, _|
        content = <<~RUBY
          # frozen_string_literal: true

          module Metanorma; module Document
            # See: https://metanorma.org/
            module #{name}
            end
          end; end

        RUBY

        Dir["#{__dir__}/../#{pc2sc name}/**/*.rb"].each do |i|
          rel_path = i.split("/../").last.gsub(/\.rb\z/, "")
          content << "require_relative #{rel_path.inspect}\n"
        end

        File.write("#{__dir__}/../#{pc2sc name}.rb", content)
      end
    end
  end
end; end; end
