# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module Formats
        autoload :BaseFormat, "#{__dir__}/formats/base_format"
        autoload :InlineFormat, "#{__dir__}/formats/inline_format"

        # All format modules that should be auto-registered. Adding a new
        # format = adding one entry here. No edits to lookup logic.
        REGISTERED = %i[InlineFormat].freeze

        class << self
          # Returns the format class registered under `name`, or nil.
          # Triggers autoload of all known format modules on first call.
          def lookup(name)
            ensure_loaded
            format_map[name]
          end

          def registered?(name)
            ensure_loaded
            format_map.key?(name)
          end

          def register(name, format_class)
            format_map[name] = format_class
            self
          end

          def unregister(name)
            format_map.delete(name)
            self
          end

          private

          def format_map
            @format_map ||= {}
          end

          def ensure_loaded
            return if @loaded

            REGISTERED.each { |mod_name| const_get(mod_name) }
            @loaded = true
          end
        end
      end
    end
  end
end
