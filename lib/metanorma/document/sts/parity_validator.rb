# frozen_string_literal: true

begin
  # Nokogiri serves the parity tooling's HTML parsing; the conversion
  # path does not use it. metanorma-document does not declare nokogiri
  # — flavors exercising the parity validator carry it themselves.
  require "nokogiri" # soft-require: LoadError-guarded optional integration
rescue LoadError
  # ParityValidator stays unusable without Nokogiri; conversion is
  # unaffected.
end

module Metanorma
  module Document
    module Sts
      # Validates that the STS-rendered HTML contains 100% of the
      # semantic content present in the Metanorma HTML output.
      module ParityValidator
        autoload :Report, "metanorma/document/sts/parity_validator/report"
        autoload :Normaliser, "metanorma/document/sts/parity_validator/normaliser"

        module_function

        def validate(mn_html:, sts_html:)
          Report.new(mn_html: mn_html, sts_html: sts_html)
        end
      end
    end
  end
end
