module Metanorma
  module Document
    module Components
      module Inline
        class FmtAnnotationBodyElement < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :date, :string
          attribute :from, :string
          attribute :to, :string
          attribute :type, :string
          attribute :reviewer, :string
          attribute :source, :string
          attribute :target, :string
          attribute :start_attr, :string
          attribute :end_attr, :string
          attribute :author, :string
          attribute :semx, SemxElement

          xml do
            element "fmt-annotation-body"
            map_attribute "id", to: :id
            map_attribute "date", to: :date
            map_attribute "from", to: :from
            map_attribute "to", to: :to
            map_attribute "type", to: :type
            map_attribute "reviewer", to: :reviewer
            map_attribute "source", to: :source
            map_attribute "target", to: :target
            map_attribute "start", to: :start_attr
            map_attribute "end", to: :end_attr
            map_attribute "author", to: :author, render_empty: true
            map_element "semx", to: :semx
          end
        end
      end
    end
  end
end
