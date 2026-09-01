# frozen_string_literal: true

module Metanorma
  module Mko
    # Registry-facing exporter: quacks like a renderer (generate_full_document)
    # so the Core::Flavors format table and the compile pipeline can select
    # mko like any output format.
    class Exporter
      def generate_full_document(document, **options)
        output = options[:output] || options[:output_filename] || "."
        to = File.directory?(output) ? output : File.dirname(output)
        Mko.export(document, to: to,
                              presentation_xml: options[:presentation_xml])
      end
    end
  end
end
