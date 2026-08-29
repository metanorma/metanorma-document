# frozen_string_literal: true

module Metanorma
  module Document
    # Attribute-keyed access to typed model objects — the one shared
    # vocabulary for walking both model trees. Flavor classes may omit
    # attributes the base trees carry (or rename them), so every read
    # is keyed on the class's lutaml declarations, never on
    # respond_to?. Included by the model-layer decomposition
    # (NativeModels) and the MKO projection alike.
    module ModelAccess
      # The attribute's value, or nil when the object does not declare
      # the attribute (or is not a typed model object at all).
      def val(obj, name)
        return nil unless serializable?(obj)

        obj.class.attributes.key?(name) ? obj.public_send(name) : nil
      end

      # Collection form: always an Array.
      def vals(obj, name)
        Array(val(obj, name))
      end

      def serializable?(obj)
        obj.is_a?(Lutaml::Model::Serializable)
      end

      # A bibdata's document identifiers; flavor trees rename the
      # attribute (:docidentifier vs :doc_identifier).
      def docids(bib)
        out = vals(bib, :docidentifier)
        out = vals(bib, :doc_identifier) if out.empty?
        out.compact
      end

      # The identifier's text: the base tree maps content to :id; iso
      # declares :value.
      def docid_text(d)
        val(d, :id) || val(d, :value)
      end
    end
  end
end
