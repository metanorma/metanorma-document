# frozen_string_literal: true

require "yaml"
require "json"

module Metanorma
  module Document
    module Presentation
      # Loads presentation profile data written in LML (the same instance
      # realization as LADL profiles) or in its YAML twin, validates it and
      # returns layers. Layers combine as base < flavor < taste.
      #
      #   PresentationProfile "iso" {
      #     layer = "flavor"
      #     flavor = "iso"
      #     settings = { date_format = "%d %B %Y" footnote_marker = "alpha" }
      #   }
      class ProfileLoader
        SCHEMA = "mn116/1"
        TYPE = "PresentationProfile"
        LAYERS = %w[base flavor taste].freeze
        KEYS = %w[layer flavor taste definition settings].freeze
        NAME = /\A[A-Za-z_][A-Za-z0-9_-]*\z/

        Layer = Data.define(:name, :layer, :flavor, :taste, :settings)

        class << self
          def from_lml(text, source: "(lml)")
            new(source, text).layers(lml_instances(text, source))
          end

          def from_yaml(text, source: "(yaml)")
            data = YAML.safe_load(text, permitted_classes: [], aliases: false)
            unless data.is_a?(Hash) && data["schema"] == SCHEMA && data["instances"].is_a?(Array)
              raise ProfileError.new("expected schema #{SCHEMA} and an instances list", source: source)
            end

            new(source, text).layers(data["instances"])
          rescue Psych::Exception => e
            line = e.respond_to?(:line) ? e.line : nil
            raise ProfileError.new("invalid YAML: #{e.message}", source: source, line: line)
          end

          def from_file(path)
            text = File.read(path, encoding: "UTF-8")
            case File.extname(path)
            when ".lml" then from_lml(text, source: path)
            when ".yaml", ".yml" then from_yaml(text, source: path)
            else raise ProfileError.new("unknown profile extension (use .lml or .yaml)", source: path)
            end
          end

          private

          def lml_instances(text, source)
            require "lutaml/lml"
            tree = Lutaml::Lml::Parser.parse(text)
            Array(tree.fetch(:members)).map do |member|
              entry = member[:instance] or
                raise ProfileError.new("only instance declarations are supported", source: source)
              if entry[:instance] || entry[:parent] || entry[:template]
                raise ProfileError.new("nested or extended instances are not profile data",
                                       source: source, instance: lml_value(entry[:name], source))
              end

              { "name" => lml_value(entry.fetch(:name), source),
                "type" => entry.fetch(:instance_type).to_s,
                "properties" => lml_properties(entry[:attributes], source) }
            end
          rescue Lutaml::Lml::ParsingError, Parsanol::ParseFailed => e
            raise ProfileError.new("invalid LML: #{e.message}", source: source)
          end

          def lml_properties(attributes, source)
            Array(attributes).each_with_object({}) do |item, result|
              next if item[:comments] || item[:definition]

              raise ProfileError.new("additive assignments are unsupported", source: source) if item[:add]

              key = item.fetch(:key).to_s
              raise ProfileError.new("duplicate property", source: source, property: key) if result.key?(key)

              result[key] = lml_value(item.fetch(:value), source, key)
            end
          end

          def lml_value(node, source, key = nil)
            unless node.is_a?(Hash)
              raise ProfileError.new("opaque value #{node.to_s.inspect}; use a literal", source: source, property: key)
            end

            case node.keys
            when [:string]
              raw = node[:string]
              Lutaml::Lml::Transform.unescape(raw == [] ? "" : raw.to_s)
            when [:number] then Integer(node[:number].to_s, 10)
            when [:boolean] then node[:boolean].to_s == "true"
            when [:null] then nil
            when [:list] then Array(node[:list]).map { |i| lml_value(i, source, key) }
            when [:key_value_map]
              Array(node[:key_value_map]).each_with_object({}) do |i, h|
                k = i.fetch(:key).to_s
                raise ProfileError.new("duplicate map key #{k}", source: source, property: key) if h.key?(k)

                h[k] = lml_value(i.fetch(:value), source, key)
              end
            else
              raise ProfileError.new("unsupported value #{node.keys.inspect}", source: source, property: key)
            end
          rescue ArgumentError => e
            raise ProfileError.new("bad number: #{e.message}", source: source, property: key)
          end
        end

        def initialize(source, text)
          @source = source
          @text = text
        end

        def layers(instances)
          out = instances.map { |row| layer(row) }
          dup = out.map(&:name).tally.find { |_, n| n > 1 }
          raise error("duplicate instance name", instance: dup.first) if dup

          out
        end

        private

        def layer(row)
          unless row.is_a?(Hash) && row["name"].is_a?(String) && row["properties"].is_a?(Hash)
            raise error("each instance needs a name and properties")
          end

          name = row["name"]
          raise error("invalid instance name", instance: name) unless name.match?(NAME)
          raise error("type must be #{TYPE}, got #{row['type'].inspect}", instance: name) unless row["type"] == TYPE

          props = row["properties"]
          unknown = props.keys - KEYS
          raise error("unknown property", instance: name, property: unknown.first) unless unknown.empty?

          kind = props["layer"]
          unless LAYERS.include?(kind)
            raise error("must be one of #{LAYERS.join(', ')}", instance: name, property: "layer")
          end

          %w[flavor taste].each do |key|
            next if props[key].nil? || props[key].is_a?(String)

            raise error("must be a string", instance: name, property: key)
          end
          check_scope(name, kind, props)
          settings = props.fetch("settings", {})
          raise error("must be a map", instance: name, property: "settings") unless settings.is_a?(Hash)

          check_value(settings, name, "settings")
          Layer.new(name: name, layer: kind, flavor: props["flavor"], taste: props["taste"],
                    settings: deep_freeze(settings))
        end

        def check_scope(name, kind, props)
          needs = { "base" => [], "flavor" => %w[flavor], "taste" => %w[taste] }.fetch(kind)
          needs.each do |key|
            raise error("required for a #{kind} layer", instance: name, property: key) if props[key].nil?
          end
          (%w[flavor taste] - needs - (kind == "taste" ? ["flavor"] : [])).each do |key|
            raise error("not allowed on a #{kind} layer", instance: name, property: key) unless props[key].nil?
          end
        end

        # Settings are a flat map of identifier keys to scalars. The LML
        # grammar has no nested map and no list inside a map literal, so
        # the YAML twin follows suit.
        def check_value(settings, name, path)
          settings.each do |k, v|
            at = "#{path}.#{k}"
            unless k.is_a?(String) && k.match?(/\A[A-Za-z_][A-Za-z0-9_]*\z/)
              raise error("keys must be identifiers", instance: name, property: at)
            end
            unless [String, Integer, TrueClass, FalseClass, NilClass].any? { |c| v.is_a?(c) }
              raise error("must be a scalar (string, number, boolean or null)", instance: name, property: at)
            end
          end
        end

        def deep_freeze(value)
          case value
          when Hash then value.each do |k, v|
            deep_freeze(k)
            deep_freeze(v)
          end
          end
          value.freeze
        end

        def error(message, instance: nil, property: nil)
          ProfileError.new(message, source: @source, line: line_of(instance, property),
                                    instance: instance, property: property)
        end

        # Best-effort line: the property inside its instance block, else the
        # instance header.
        def line_of(instance, property)
          return nil unless instance

          lines = @text.lines
          start = lines.index { |l| l.include?(instance) && l.match?(/PresentationProfile|name:/) }
          return nil unless start

          if property
            key = property[/\A[^.\[]+/]
            offset = lines[start..].index { |l| l.match?(/\b#{Regexp.escape(key)}\b\s*[=:]/) }
            return start + offset + 1 if offset
          end
          start + 1
        end
      end
    end
  end
end
