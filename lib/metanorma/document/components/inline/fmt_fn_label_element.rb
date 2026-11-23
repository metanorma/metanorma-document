# frozen_string_literal: true

require_relative "fmt_ladl_label_data"

module Metanorma
  module Document
    module Components
      module Inline
        class FmtFnLabelElement < Lutaml::Model::Serializable
          include RenderedDisplay

          attribute :fmt_ladl_label_data, FmtLadlLabelData

          attribute :text, :string, collection: true
          attribute :span, SpanElement, collection: true
          attribute :semx, SemxElement, collection: true
          attribute :tab, TabElement, collection: true

          xml do
            element "fmt-fn-label"
            mixed_content
            map_element "fmt-ladl-label-data", to: :fmt_ladl_label_data
            map_content to: :text
            map_element "span", to: :span
            map_element "semx", to: :semx
            map_element "tab", to: :tab
          end
        end
      end
    end
  end
end
