# frozen_string_literal: true

module Metanorma
  module Document
    module Presentation
      # Declarative behaviours: rules built from profile settings only.
      # A flavor or taste changes a behaviour by setting keys in its
      # profile layer; it adds no code.
      #
      #   date_format          strftime pattern that replaces the format given
      #                        on each date, or "own" to render each date in
      #                        its own format. Unset: dates are not rendered.
      #   footnote_sup         true (default): the marker is superscript
      #   footnote_open        text before the marker number (default "")
      #   footnote_close       text after the marker number (default "")
      #   footnote_delim_scope "all" (default) or "body": delimiters only
      #                        outside tables and figures
      #   section_order        comma-separated regions in display order, see
      #                        DisplayOrder (writes displayorder on sections)
      #   contributor_name_order  "given_family" (default) or "family_given"
      module Behaviours
        KEYS = %w[date_format footnote_sup footnote_open footnote_close
                  footnote_delim_scope contributor_name_order section_order].freeze
        NAME_ORDERS = %w[given_family family_given].freeze
        DELIM_SCOPES = %w[all body].freeze

        module_function

        # The rules a settings map asks for, in a fixed order. A behaviour
        # whose keys are all unset adds no rule, so an empty profile is a
        # no-op.
        def rules_for(settings)
          check(settings)
          rules = []
          rules << DateFormat.new(format: own_format(settings["date_format"])) if settings["date_format"]
          rules << FootnoteMarker.new(**footnote_options(settings)) if footnote?(settings)
          rules << DisplayOrder.new(regions: section_regions(settings["section_order"])) if settings["section_order"]
          rules << ContributorNameOrder.new(order: settings["contributor_name_order"]) if settings["contributor_name_order"]
          rules
        end

        # The same profile with the rules its settings describe.
        def profile(profile)
          Profile.new(name: profile.name, settings: profile.settings, rules: rules_for(profile.settings))
        end

        def section_regions(value)
          value.split(",").map(&:strip)
        end

        def own_format(value)
          value == "own" ? nil : value
        end

        def footnote?(settings)
          settings.keys.any? { |k| k.start_with?("footnote_") && KEYS.include?(k) }
        end

        def footnote_options(settings)
          { sup: settings.fetch("footnote_sup", true), open: settings["footnote_open"].to_s,
            close: settings["footnote_close"].to_s, scope: settings.fetch("footnote_delim_scope", "all") }
        end

        def check(settings)
          bad = lambda do |key, msg|
            raise ProfileError.new(msg, instance: nil, property: "settings.#{key}")
          end
          if settings.key?("date_format") && !(settings["date_format"].is_a?(String) && !settings["date_format"].empty?)
            bad.call("date_format", "must be a non-empty strftime string")
          end
          if settings.key?("footnote_sup") && ![true, false].include?(settings["footnote_sup"])
            bad.call("footnote_sup", "must be true or false")
          end
          %w[footnote_open footnote_close].each do |k|
            bad.call(k, "must be a string") if settings.key?(k) && !settings[k].is_a?(String)
          end
          if settings.key?("footnote_delim_scope") && !DELIM_SCOPES.include?(settings["footnote_delim_scope"])
            bad.call("footnote_delim_scope", "must be one of #{DELIM_SCOPES.join(', ')}")
          end
          if settings.key?("section_order")
            regions = settings["section_order"].is_a?(String) ? section_regions(settings["section_order"]) : []
            unknown = regions - DisplayOrder::REGIONS
            if regions.empty? || !unknown.empty?
              detail = unknown.empty? ? "" : "; unknown: #{unknown.join(', ')}"
              bad.call("section_order", "must list regions from #{DisplayOrder::REGIONS.join(', ')}#{detail}")
            end
          end
          if settings.key?("contributor_name_order") && !NAME_ORDERS.include?(settings["contributor_name_order"])
            bad.call("contributor_name_order", "must be one of #{NAME_ORDERS.join(', ')}")
          end
        end
      end
    end
  end
end

require_relative "behaviours/date_format"
require_relative "behaviours/footnote_marker"
require_relative "behaviours/contributor_name_order"
require_relative "behaviours/display_order"
