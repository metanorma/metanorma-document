# frozen_string_literal: true

module Metanorma
  module Mirror
    module IdStrategy
      # Preserve all IDs as-is (default behavior).
      # UUID elements keep their UUID IDs. Explicit IDs are unchanged.
      class Preserve < Base
      end
    end
  end
end
