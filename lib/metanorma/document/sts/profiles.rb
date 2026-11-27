# frozen_string_literal: true

module Metanorma
  module Document
    module Sts
      # Registry of publisher profiles. Flavor gems register their profile
      # at load time; the engine resolves profiles by name and carries a
      # neutral default (no publisher identity, no structure overrides)
      # for direct engine use.
      module Profiles
        @profiles = {}

        class << self
          # Registers (or replaces) a profile. The name is the key; a
          # re-registration replaces the prior entry so a flavor can
          # refine its profile across load order.
          #
          # @param profile [Profile]
          # @return [Profile]
          def register(profile)
            raise ArgumentError, "not a Metanorma::Document::Sts::Profile" unless profile.is_a?(Profile)

            @profiles[profile.name] = profile
          end

          # @param name [Symbol]
          # @return [Profile, nil]
          def fetch(name)
            @profiles[name]
          end

          # @param name [Symbol]
          # @return [Profile] raises KeyError with the registered names
          #   when the profile is unknown.
          def resolve(name)
            @profiles.fetch(name) do
              raise KeyError,
                    "no STS profile registered under #{name.inspect} " \
                    "(registered: #{@profiles.keys.map(&:inspect).join(', ')})"
            end
          end

          # The neutral profile: used when the engine runs without a
          # publisher profile (direct engine use, engine specs). It
          # assumes no publisher identity and registers no structure
          # overrides.
          #
          # @return [Profile]
          def default
            @default ||= Profile.new(name: :default)
          end

          # @return [Array<Symbol>] registered profile names.
          def names
            @profiles.keys
          end

          # Removes a registration (spec hygiene; the registry is global
          # state). No-op when the name is unknown.
          #
          # @param name [Symbol]
          def delete(name)
            @profiles.delete(name)
            nil
          end

          # Drops all registrations. Spec support only — profiles are
          # global state.
          def reset!
            @profiles = {}
            @default = nil
            nil
          end
        end
      end
    end
  end
end
