# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # Type which allows date and time to be specified as either a Gregorian
      # date and time, as specified in <<iso8601>>, as text, or as both.
      class DateTime < Lutaml::Model::Serializable
        attribute :text, :string
        attribute :content, :string

        xml do
          map_attribute "text", to: :text
          map_content to: :content
        end
      end
    end
  end
end
