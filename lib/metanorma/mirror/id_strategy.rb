# frozen_string_literal: true

module Metanorma
  module Mirror
    module IdStrategy
      autoload :Preserve, "#{__dir__}/id_strategy/preserve"
      autoload :Positional, "#{__dir__}/id_strategy/positional"

      # Base class for ID assignment strategies.
      #
      # A strategy controls how element IDs are assigned during mirror
      # generation. Subclasses override assign_id and finalize!.
      #
      # assign_id(element)  — called per element during node construction
      # finalize!(document) — called once after the full mirror tree is built
      #
      # Adding a new strategy = adding a new class. No changes to handlers
      # or the converter (OCP).
      class Base
        # Returns the ID string to assign to the mirror node for this element.
        def assign_id(element)
          SafeAttr.read(element, :id)
        end

        # Post-process the completed mirror document after all IDs are assigned.
        # Use this to translate cross-reference targets, etc.
        # Returns the (possibly modified) document.
        def finalize!(document)
          document
        end
      end
    end
  end
end
