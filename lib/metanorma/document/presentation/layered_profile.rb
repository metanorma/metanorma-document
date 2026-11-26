# frozen_string_literal: true

module Metanorma
  module Document
    module Presentation
      # Resolves profile layers into one Profile: base < flavor < taste.
      # Settings merge key by key; a key set in a later layer replaces the
      # earlier value.
      module LayeredProfile
        ORDER = %w[base flavor taste].freeze

        module_function

        def resolve(layers, flavor: nil, taste: nil, name: nil)
          chosen = ORDER.flat_map do |kind|
            layers.select { |l| l.layer == kind && applies?(l, kind, flavor, taste) }
          end
          ORDER.each do |kind|
            same = chosen.select { |l| l.layer == kind }
            next if same.size <= 1

            raise ProfileError.new("more than one #{kind} layer applies: #{same.map(&:name).join(', ')}",
                                   instance: same.last.name)
          end
          settings = chosen.reduce({}) { |acc, l| merge(acc, l.settings) }
          Profile.new(name: name || chosen.map(&:name).join("<"), settings: settings)
        end

        def applies?(layer, kind, flavor, taste)
          case kind
          when "base" then true
          when "flavor" then flavor && layer.flavor == flavor.to_s
          when "taste" then taste && layer.taste == taste.to_s && (layer.flavor.nil? || layer.flavor == flavor.to_s)
          end
        end

        def merge(base, over)
          base.merge(over)
        end
      end
    end
  end
end
