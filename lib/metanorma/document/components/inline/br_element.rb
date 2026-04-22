module Metanorma
  module Document
    module Components
      module Inline
        class BrElement < Lutaml::Model::Serializable
          xml do
            element "br"
          end
        end
      end
    end
  end
end
