# frozen_string_literal: true

module Metanorma
  module Html
    module Concerns
      # Plain-text extraction from model nodes, mixed into BaseRenderer.
      # Used wherever rendered output needs a text-only form (titles,
      # labels, captions, ToC entries). Walks `element_order` and typed
      # attributes directly on the model — never strips tags from
      # rendered HTML.
      module TextExtraction
        def extract_plain_text(node)
          return node.to_s if node.is_a?(String)
          return extract_text_value(node).to_s unless node.is_a?(Lutaml::Model::Serializable)

          parts = []
          xml_mapping = node.class.mappings_for(:xml, node.lutaml_register)

          if node.element_order.is_a?(Array) && xml_mapping
            element_to_attr =
              Renderers::ElementOrderTraversal.element_to_attr_map(xml_mapping)

            indices = Hash.new(0)
            node.element_order.each do |el|
              next unless el.is_a?(Lutaml::Xml::Element)

              if el.text?
                parts << el.text_content.to_s
              elsif el.name == "tab"
                parts << " "
              # rubocop:disable Lint/DuplicateBranch
              elsif el.name == "br"
                parts << " "
              # rubocop:enable Lint/DuplicateBranch
              elsif el.element?
                attr_name = element_to_attr[el.name]
                if attr_name
                  coll = node.public_send(attr_name)
                  obj = if coll.is_a?(Array)
                          idx = indices[attr_name]
                          indices[attr_name] += 1
                          coll[idx]
                        else
                          coll
                        end
                  text = extract_plain_text(obj)
                  parts << (text.empty? ? " " : text)
                elsif el.name == "span"
                  parts << " "
                end
              end
            end
          end

          if parts.join.strip.empty?
            t = safe_attr(node, :text)
            parts << (t.is_a?(Array) ? t.join : t.to_s) if t
          end

          parts.join.strip.gsub(" ", " ")
        end

        def extract_text_value(val)
          return nil if val.nil?
          return val if val.is_a?(String)

          if val.is_a?(Array)
            val.map { |v| extract_text_value(v) }.join
          elsif val.is_a?(Lutaml::Model::Serializable)
            c = safe_attr(val, :content)
            if c && !c.equal?(val)
              extract_text_value(c)
            else
              t = safe_attr(val, :text)
              if t
                extract_text_value(t)
              else
                v = safe_attr(val, :value)
                if v
                  extract_text_value(v)
                else
                  val.to_s
                end
              end
            end
          else
            val.to_s
          end
        end
      end
    end
  end
end
