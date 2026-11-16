# frozen_string_literal: true

require "liquid"

module Metanorma
  module Html
    # One ordered search path for both entry templates and Liquid partials.
    # Instances belong to a render, never to Liquid's global environment.
    class TemplateResolver
      def initialize(directories)
        @directories = directories.compact.map { |dir| File.expand_path(dir) }
      end

      def resolve(template_name)
        unless template_name.match?(%r{\A(?:[\w-]+/)*[\w-]+\.html\.liquid\z})
          raise Liquid::FileSystemError, "Invalid template name: #{template_name}"
        end

        @directories.each do |dir|
          path = File.join(dir, template_name)
          next unless File.file?(path)

          unless File.realpath(path).start_with?("#{File.realpath(dir)}/")
            raise Liquid::FileSystemError, "Template outside directory: #{template_name}"
          end

          return path
        end
        raise Liquid::FileSystemError, "No such template: #{template_name}"
      end

      def read_template_file(template_name)
        unless template_name.match?(%r{\A(?:[\w-]+/)*[\w-]+\z})
          raise Liquid::FileSystemError, "Invalid partial name: #{template_name}"
        end

        parts = template_name.split("/")
        parts[-1] = "_#{parts.last}.html.liquid"
        File.read(resolve(parts.join("/")))
      end
    end
  end
end
