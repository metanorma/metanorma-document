# frozen_string_literal: true

require "fileutils"
require "lutaml/uml"
require "tilt"

require_relative "class_gen/util"

module Metanorma; module Document; module Devel
  # Generates the class structure based on their LutaML
  # descriptions.
  #
  # This is called by bin/class_gen
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
               "models", branch: "webdev778/iso-3166-code"
      add_repo :Relaton, "https://github.com/relaton/relaton-models",
               "models", branch: "main"
      add_repo :StandardDocument, "https://github.com/metanorma/metanorma-model-standoc",
               "models/standard_document", branch: "main"
      add_repo :IsoDocument, "https://github.com/metanorma/metanorma-model-iso",
               "models/iso_document", branch: "main"

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
                warn "!! Different path: #{new_f} => #{existing_classes[class_name]}"
                mkdir_p(File.dirname(new_f))
                ln_s existing_classes[class_name], new_f
              else
                warn "!!!!!! File #{base_f} doesn't exist in a base repo!"
              end
            end
          end
        end
      end
    end

    def parse_combined_repo
      Dir["#{@tmp_path}/combined/views/**/*.lutaml"].each do |file|
        puts "... working on #{file} ..."
        pp Lutaml::Uml::Parsers::Dsl.parse(File.open(file))
      end
    end
  end
end; end; end
