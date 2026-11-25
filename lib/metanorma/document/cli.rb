# frozen_string_literal: true

require "optparse"
require "json"
require "fileutils"
require "metanorma-core"

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
        :headless,
        keyword_init: true,
      )

      ValidateOptions = Struct.new(
        :xml_path,
        :output,
        :flavor,
        :model_parse,
        keyword_init: true,
      )

      def self.run(argv)
        command = argv.shift
        case command
        when "to-mirror"
          to_mirror(argv)
        when "to-html"
          to_html(argv)
        when "validate"
          validate(argv)
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

      def self.validate(argv)
        options = parse_validate_options(argv)
        checks = []
        checks << check_encoding(options)
        checks << check_wellformed(options)
        checks << check_document_kind(options)
        checks << check_model_parse(options) if options.model_parse

        report = {
          "file" => options.xml_path,
          "valid" => checks.all? { |c| c["status"] == "pass" },
          "checks" => checks,
        }
        payload = JSON.pretty_generate(report)
        if options.output
          File.write(options.output, payload)
        else
          puts payload
        end
        report["valid"] ? 0 : 1
      end

      def self.parse_validate_options(argv)
        opts = ValidateOptions.new(model_parse: false)
        parser = OptionParser.new do |o|
          o.on("--out FILE") { |v| opts.output = v }
          o.on("--flavor NAME") { |v| opts.flavor = v }
          o.on("--model-parse") { opts.model_parse = true }
        end
        parser.parse!(argv)
        opts.xml_path = argv.shift
        raise Error, "Usage: metanorma-document validate FILE [--out FILE] [--flavor NAME] [--model-parse]" if opts.xml_path.nil?

        opts
      end

      # Byte-level UTF-8 validity, streamed in chunks: no full-document
      # materialization for the common valid case.
      def self.check_encoding(options)
        result = { "check" => "encoding", "status" => "pass" }
        base = 0
        carry = +""
        File.open(options.xml_path, "rb") do |f|
          while (bytes = f.read(1 << 20))
            chunk = carry + bytes
            # Keep a potential partial multibyte sequence for the next
            # round; a complete chunk must validate cleanly.
            cut = chunk.bytesize - 3
            cut = 0 if cut.negative?
            rest = chunk.byteslice(0, cut)
            rest.force_encoding("UTF-8")
            unless rest.valid_encoding?
              result["status"] = "fail"
              result["error"] = "invalid UTF-8 byte sequence"
              result["byte"] = base
              return result
            end
            base += rest.bytesize
            carry = chunk.byteslice(cut, chunk.bytesize - cut) || +""
          end
        end
        carry.force_encoding("UTF-8")
        unless carry.empty? || carry.valid_encoding?
          result["status"] = "fail"
          result["error"] = "invalid UTF-8 byte sequence (tail)"
          result["byte"] = base
          return result
        end
        result
      end

      # Well-formedness via the moxml/leptris parser (the fast engine;
      # never the XSLT snapshot machinery).
      def self.check_wellformed(options)
        result = { "check" => "wellformed", "status" => "pass" }
        begin
          require "moxml"
          doc = Moxml.new.parse(File.read(options.xml_path))
          result["root"] = doc.root&.name
        rescue StandardError => e
          result["status"] = "fail"
          result["error"] = e.message.to_s[0, 300]
        end
        result
      end

      # Presentation vs semantic root detection (presentation inputs
      # are the render contract; semantic roots need the compile).
      def self.check_document_kind(options)
        result = { "check" => "document_kind", "status" => "pass" }
        begin
          require "moxml"
          doc = Moxml.new.parse(File.read(options.xml_path))
          root = doc.root
          type = nil
          root&.attributes&.each { |k, v| type = v if k == "type" }
          result["kind"] = type || "unspecified"
          result["root"] = root&.name
        rescue StandardError => e
          result["status"] = "fail"
          result["error"] = e.message.to_s[0, 300]
        end
        result
      end

      # Full model parse through the flavor registry (catch-all fast
      # path): model-level contract violations surface here.
      def self.check_model_parse(options)
        result = { "check" => "model_parse", "status" => "pass" }
        begin
          require "metanorma/html"
          flavor = options.flavor&.to_sym
          renderer = Metanorma::Html::StandardRenderer.new(flavor: flavor)
          renderer.parse(File.read(options.xml_path))
        rescue StandardError => e
          result["status"] = "fail"
          result["error"] = "#{e.class}: #{e.message}"[0, 300]
        end
        result
      end

      def self.to_html(argv)
        options = parse_to_html_options(argv)
        execute_to_html(options)
      end

      def self.parse_to_html_options(argv)
        options = ToHtmlOptions.new(output: nil, flavor: nil, headless: false)

        parser = OptionParser.new do |opts|
          opts.banner = "Usage: metanorma-document to-html <xml_path> [options]"

          opts.on("-o", "--output PATH",
                  "Output HTML path (default: stdout)") do |path|
            options.output = path
          end

          opts.on("--headless", "Emit the body layout inside a div without a head") do
            options.headless = true
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
        # Resolve tastes before the mirror parser's class-name lookup:
        # a taste uses its base model while retaining its own HTML theme.
        step = Mirror::Output::Pipeline::Steps::ParseXml.new
        requested = options.flavor || step.infer_flavor(options.xml_path)
        flavor = canonical_flavor(requested).to_s
        doc = step.flavor_class(flavor).from_xml(File.read(options.xml_path))
        theme = Html::Theme.load(requested) if requested.to_s != flavor
        write_output(Html::Generator.generate(doc, theme: theme,
                                                   headless: options.headless), options.output)
      end

      # Tastes carry no model classes of their own: the mirror pipeline's
      # dispatch requires metanorma/<flavor>/document, so a taste name
      # ("wmo") silently falls back to the Standoc root and the flavor
      # walk then misses the taste's renderer. Follow the base_flavor
      # chain to the owning model ("wmo" -> "iho"); unknown names pass
      # through untouched.
      def self.canonical_flavor(flavor)
        return flavor unless flavor

        require "metanorma-core"
        begin
          # Taste entries live in metanorma-taste; without it the table
          # has no taste rows and taste2flavor cannot resolve.
          require "metanorma-taste" # soft-require: LoadError-guarded optional
        rescue LoadError
          nil
        end
        Metanorma::Core::FlavorLoader.taste2flavor(flavor).to_s
      rescue LoadError, NameError
        flavor
      end

      def self.usage
        <<~USAGE
          Usage: metanorma-document <command> [options]

          Commands:
            to-mirror    Convert presentation XML to mirror JSON
            to-html      Render presentation XML to standalone HTML
            validate     Standalone diagnostics: encoding, well-formedness,
                         document kind, optional model parse (JSON report)

          Run `metanorma-document <command> --help` for command-specific options.
        USAGE
      end
    end
  end
end
