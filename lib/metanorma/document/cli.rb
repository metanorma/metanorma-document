# frozen_string_literal: true

require "optparse"
require "fileutils"

module Metanorma
  module Document
    class CLI
      class Error < StandardError; end

      ToMirrorOptions = Struct.new(
        :xml_path,
        :output,
        :flavor,
        :id_strategy,
        :title,
        keyword_init: true,
      )

      ToHtmlOptions = Struct.new(
        :xml_path,
        :output,
        :flavor,
        keyword_init: true,
      )

      def self.run(argv)
        command = argv.shift
        case command
        when "to-mirror"
          to_mirror(argv)
        when "to-html"
          to_html(argv)
        when nil, "-h", "--help"
          puts usage
        else
          raise Error, "Unknown command: #{command}"
        end
      end

      def self.to_mirror(argv)
        options = parse_to_mirror_options(argv)
        execute_to_mirror(options)
      end

      def self.parse_to_mirror_options(argv)
        options = ToMirrorOptions.new(output: nil, flavor: nil,
                                      id_strategy: nil, title: nil)

        parser = OptionParser.new do |opts|
          opts.banner = "Usage: metanorma-document to-mirror <xml_path> [options]"

          opts.on("-o", "--output PATH",
                  "Output JSON path (default: stdout)") do |path|
            options.output = path
          end

          opts.on("-f", "--flavor FLAVOR",
                  "Document flavor (default: auto-detect)") do |flavor|
            options.flavor = flavor
          end

          opts.on("--id-strategy STRATEGY",
                  "ID strategy: preserve (default), positional") do |strategy|
            case strategy
            when "positional"
              options.id_strategy = Mirror::IdStrategy::Positional.new
            when "preserve"
              options.id_strategy = Mirror::IdStrategy::Preserve.new
            else
              raise Error,
                    "Unknown ID strategy: #{strategy}. Use 'preserve' or 'positional'."
            end
          end

          opts.on("--title TITLE", "Document title override") do |title|
            options.title = title
          end
        end

        parser.parse!(argv)

        xml_path = argv.shift
        raise Error, "XML path required" unless xml_path
        raise Error, "File not found: #{xml_path}" unless File.exist?(xml_path)

        options.xml_path = xml_path
        options
      end

      def self.execute_to_mirror(options)
        pipeline = Mirror::Output::Pipeline.new(
          xml_path: options.xml_path,
          flavor: options.flavor,
          title: options.title,
          id_strategy: options.id_strategy,
        )
        guide = pipeline.process

        json = Mirror::Serialization::JsonSerializer.serialize_pretty(guide.content)
        write_output(json, options.output)
      end

      def self.write_output(json, output_path)
        if output_path
          FileUtils.mkdir_p(File.dirname(output_path))
          File.write(output_path, json)
        else
          $stdout.puts(json)
        end
      end

      def self.to_html(argv)
        options = parse_to_html_options(argv)
        execute_to_html(options)
      end

      def self.parse_to_html_options(argv)
        options = ToHtmlOptions.new(output: nil, flavor: nil)

        parser = OptionParser.new do |opts|
          opts.banner = "Usage: metanorma-document to-html <xml_path> [options]"

          opts.on("-o", "--output PATH",
                  "Output HTML path (default: stdout)") do |path|
            options.output = path
          end

          opts.on("-f", "--flavor FLAVOR",
                  "Document flavor (default: auto-detect)") do |flavor|
            options.flavor = flavor
          end
        end

        parser.parse!(argv)

        xml_path = argv.shift
        raise Error, "XML path required" unless xml_path
        raise Error, "File not found: #{xml_path}" unless File.exist?(xml_path)

        options.xml_path = xml_path
        options
      end

      def self.execute_to_html(options)
        # Metanorma::Html is autoloaded from metanorma/document.
        # Reuse the mirror pipeline's flavor inference/model dispatch so
        # to-html and to-mirror parse documents identically.
        step = Mirror::Output::Pipeline::Steps::ParseXml.new
        flavor = options.flavor || step.infer_flavor(options.xml_path)
        doc = step.flavor_class(flavor).from_xml(File.read(options.xml_path))
        write_output(Html::Generator.generate(doc), options.output)
      end

      def self.usage
        <<~USAGE
          Usage: metanorma-document <command> [options]

          Commands:
            to-mirror    Convert presentation XML to mirror JSON
            to-html      Render presentation XML to standalone HTML

          Run `metanorma-document <command> --help` for command-specific options.
        USAGE
      end
    end
  end
end
