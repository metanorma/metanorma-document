# frozen_string_literal: true

# Moxml's Nokogiri adapter strips whitespace-only text nodes from children,
# which drops significant spaces in mixed content (e.g., "Table 1" → "Table1").
# This patch preserves whitespace text nodes that are between element siblings,
# as they are significant in presentation XML mixed content.
Moxml::Adapter::Nokogiri.class_eval do
  class << self
    remove_method :children
  end

  def self.children(node)
    node.children.to_a
  end
end

# Lutaml::Xml::XmlElement#order also strips whitespace-only text nodes.
# Preserve them so walk_ordered can render them between inline elements.
Lutaml::Xml::XmlElement.class_eval do
  remove_method :order

  def order
    return @order_cache if @order_cache

    @order_cache = children.filter_map do |child|
      if child.text?
        # Preserve ALL text nodes including whitespace-only ones.
        # Upstream strips whitespace here, but mixed content in
        # presentation XML requires spaces between inline elements.
        Lutaml::Xml::Element.new("Text", "text",
                                 text_content: child.text,
                                 node_type: :text)
      elsif child.cdata?
        Lutaml::Xml::Element.new("Text", "#cdata-section",
                                 text_content: child.text,
                                 node_type: :cdata)
      elsif child.comment?
        nil
      else
        Lutaml::Xml::Element.new("Element", child.unprefixed_name,
                                 node_type: :element,
                                 namespace_uri: child.namespace_uri,
                                 namespace_prefix: child.namespace_prefix)
      end
    end
  end
end
