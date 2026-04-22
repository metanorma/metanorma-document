# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Change
        # The actual content
        # changes that applies to the specified portion of textual content.
        # This is used both by the _ContentModify_ and _AttributeModify_ models
        # as their content are treated as pure text.
        class ContentChangeAction < Lutaml::Model::Serializable
          attribute :action, :string
          attribute :from, :integer
          attribute :to, :integer
          attribute :text, :string
          attribute :length, :integer

          xml do
            element "content-change-action"
            map_attribute "action", to: :action
            map_attribute "from", to: :from
            map_attribute "to", to: :to
            map_attribute "text", to: :text
            map_attribute "length", to: :length
          end
        end
      end
    end
  end
end
