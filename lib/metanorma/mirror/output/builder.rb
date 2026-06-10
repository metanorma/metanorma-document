# frozen_string_literal: true

require "fileutils"

module Metanorma
  module Mirror
    module Output
      class Builder
        attr_reader :xml_path, :output_path, :format, :options

        def initialize(xml_path:, output_path:, format: :inline, **options)
          @xml_path = xml_path
          @output_path = output_path
          @format = format
          @options = options
        end

        def build
          pipeline = Pipeline.new(
            xml_path: @xml_path,
            flavor: @options[:flavor],
            title: @options[:title] || File.basename(@xml_path, ".*"),
          )

          guide = pipeline.process

          format_class = Formats::FORMAT_MAP[@format]
          raise ArgumentError, "Unknown format: #{@format}" unless format_class

          formatter = format_class.new(dist_dir: @options[:dist_dir])
          formatter.write(@output_path, guide, title: @options[:title])

          @output_path
        end
      end
    end
  end
end
