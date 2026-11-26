# frozen_string_literal: true

module Metanorma
  module Document
    module Sts
      # Result of validating a NISO STS XML document. Findings carry a
      # severity: `errors` fail the gate ({#valid?}), `warnings` are
      # report-only.
      class ValidationReport
        Finding = Struct.new(:rule_id, :message, :xpath, :severity,
                             keyword_init: true)

        attr_reader :errors, :warnings

        def initialize(errors: [], warnings: [])
          @errors = errors
          @warnings = warnings
        end

        # Only error findings fail validation; warnings never do.
        def valid?
          errors.empty?
        end

        def add(rule_id:, message:, xpath: nil, severity: :error)
          finding = Finding.new(rule_id: rule_id, message: message,
                                xpath: xpath, severity: severity)
          (severity == :warning ? @warnings : @errors) << finding
        end

        def freeze
          @errors.freeze
          @warnings.freeze
          super
        end

        def to_s
          head = if valid?
                   "STS validation passed (0 errors"
                 else
                   "STS validation FAILED (#{errors.size} errors"
                 end
          head += ", #{warnings.size} warnings" unless warnings.empty?
          lines = (errors + warnings).map { |e| format_finding(e) }
          (["#{head})#{':' unless lines.empty?}"] + lines).join("\n")
        end

        private

        def format_finding(finding)
          where = finding.xpath ? " at #{finding.xpath}" : ""
          "  [#{finding.severity}] [#{finding.rule_id}] " \
            "#{finding.message}#{where}"
        end
      end
    end
  end
end
