# frozen_string_literal: true

module Metanorma
  module Document
    module Presentation
      # Raised for an invalid profile. The message names the source, the
      # line (when it can be found), the instance and the property.
      class ProfileError < StandardError
        attr_reader :source, :line, :instance, :property

        def initialize(message, source: nil, line: nil, instance: nil, property: nil)
          @source = source
          @line = line
          @instance = instance
          @property = property
          where = [source || "profile", line && "line #{line}",
                   instance && "instance #{instance}",
                   property && "property #{property}"].compact.join(", ")
          super("#{where}: #{message}")
        end
      end
    end
  end
end
