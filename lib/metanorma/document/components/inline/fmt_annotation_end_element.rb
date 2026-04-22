module Metanorma
  module Document
    module Components
      module Inline
        class FmtAnnotationEndElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :date, :string
          attribute :source, :string
          attribute :target, :string
          attribute :start_attr, :string
          attribute :author, :string

          xml do
            element "fmt-annotation-end"
            map_attribute "id", to: :id
            map_attribute "date", to: :date
            map_attribute "source", to: :source
            map_attribute "target", to: :target
            map_attribute "start", to: :start_attr
            map_attribute "author", to: :author, render_empty: true
          end
        end
      end
    end
  end
end
