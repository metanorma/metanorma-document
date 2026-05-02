# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module Blocks
      class BasicBlock < Lutaml::Model::Serializable
        xml do
          element "basic-block"
        end
      end
    end
  end
end
