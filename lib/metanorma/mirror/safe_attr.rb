# frozen_string_literal: true

module Metanorma
  module Mirror
    module SafeAttr
      def self.read(element, attr_name)
        klass = element.class
        return nil unless klass.respond_to?(:attributes)
        return nil unless klass.attributes.key?(attr_name)

        element.public_send(attr_name)
      end
    end
  end
end
