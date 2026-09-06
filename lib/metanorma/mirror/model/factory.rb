# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      # Semantic dispatcher: the wire's "type" and "content" shape pick
      # the model class; deserialization itself is the framework's
      # from_hash on the chosen class.
      class Factory
        INVALID_INPUT = "Factory.from_hash expects a Hash, got %<class>s"
        MISSING_TYPE = "Factory.from_hash requires a 'type' key, got %<hash>s"

        def self.from_hash(hash)
          unless hash.is_a?(Hash)
            raise ArgumentError, format(INVALID_INPUT, class: hash.class)
          end

          case hash["type"]
          when "text" then Text.from_hash(hash)
          when "soft_break" then SoftBreak.from_hash(hash)
          when nil
            raise ArgumentError, format(MISSING_TYPE, hash: hash.inspect)
          else
            if hash["content"].is_a?(Array)
              Container.from_hash(hash)
            else
              Leaf.from_hash(hash)
            end
          end
        end
      end
    end
  end
end
