module Metanorma
  module Document
    module Components
      module Inline
        class FmtAnnotationStartElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :date, :string
          attribute :source, :string
          attribute :target, :string
          attribute :end_attr, :string
          attribute :author, :string

          xml do
            element "fmt-annotation-start"
            map_attribute "id", to: :id
            map_attribute "date", to: :date
            map_attribute "source", to: :source
            map_attribute "target", to: :target
            map_attribute "end", to: :end_attr
            map_attribute "author", to: :author, render_empty: true
          end
        end
      end
    end
  end
end
