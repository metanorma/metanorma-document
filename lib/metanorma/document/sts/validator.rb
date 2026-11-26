# frozen_string_literal: true

require "moxml"

module Metanorma
  module Document
    module Sts
      # Validator engine for NISO STS XML. The engine carries the
      # machinery — Moxml parsing, rule iteration, findings with
      # severity — while the RULES are publisher data: each flavor
      # subclasses in its own rule set (metanorma-iso: the IEC/ISO
      # Coding Guidelines ed 2.1 rules; metanorma-oiml: the OIML X 999
      # rules). The neutral engine has no rules and accepts everything.
      #
      # Protocol (subclass extension points):
      # - {#rules} — the rule objects to apply;
      # - {#apply_rule} — how one rule reports findings. The engine
      #   default implements the lambda-rule protocol: the rule carries
      #   an +apply+ callable invoked with +(doc, report, rule)+ that
      #   calls +report.add+ for each violation.
      class Validator
        # A rule binds an id + message + severity to its behavior.
        # Plain data — flavors may subclass or replace with their own
        # Struct.
        Rule = Struct.new(:id, :message, :apply, :severity,
                          keyword_init: true)

        # @param xml [String, Pathname, #read] STS XML.
        # @return [ValidationReport]
        def validate(xml)
          doc = parse(xml)
          report = ValidationReport.new
          rules.each do |rule|
            apply_rule(rule, doc, report)
          end
          report
        end

        # ---- Extension points (public) -------------------------------

        # The rule objects. Neutral engine: none (everything valid).
        # Flavor subclasses return their rule set.
        def rules
          []
        end

        # Applies one rule. Default: the lambda-rule protocol — the rule
        # carries an +apply+ callable invoked with (doc, report, rule).
        # A flavor whose rules follow a different shape overrides this
        # method (e.g. the ISO validator's context/check rules).
        def apply_rule(rule, doc, report)
          rule.apply.call(doc, report, rule)
        end

        private

        def parse(xml)
          case xml
          when Pathname then Moxml.parse(xml.read)
          when ->(x) { x.respond_to?(:read) } then Moxml.parse(x.read)
          else Moxml.parse(xml.to_s)
          end
        end
      end
    end
  end
end
