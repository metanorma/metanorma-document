# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      module Inline
        module TextExtractor
          def self.extract_element_text(element)
            return "" unless element.is_a?(Lutaml::Model::Serializable)

            text = SafeAttr.read(element, :text)
            if text.is_a?(Array)
              joined = text.join.strip
              return joined unless joined.empty?
            elsif text.is_a?(String) && !text.strip.empty?
              return text
            end

            content = SafeAttr.read(element, :content)
            if content.is_a?(Array)
              parts = content.filter_map do |c|
                next c.to_s if c.is_a?(String)
                next extract_element_text(c) if c.is_a?(Lutaml::Model::Serializable)

                nil
              end
              joined = parts.join.strip
              return joined unless joined.empty?
            elsif content.is_a?(String) && !content.strip.empty?
              return content
            end

            ""
          end

          def self.extract_formatted_text(element)
            return "" unless element
            return element.to_s unless element.is_a?(Lutaml::Model::Serializable)

            parts = []
            element.each_mixed_content do |node|
              case node
              when String
                parts << node
              when Lutaml::Model::Serializable
                inner = extract_formatted_text(node)
                parts << inner if inner && !inner.empty?
              end
            end
            result = parts.join.strip
            result.empty? ? extract_element_text(element) : result
          end

          def self.extract_text_from_model(node)
            case node
            when Metanorma::Document::Components::Inline::TabElement
              " "
            when Metanorma::Document::Components::Inline::BrElement
              "\n"
            else
              text = extract_formatted_text(node)
              text.empty? ? extract_element_text(node) : text
            end
          end

          def self.extract_fn_label(element)
            label = SafeAttr.read(element, :fmt_fn_label)
            return extract_element_text(element) unless label

            extract_formatted_text(label)
          end

          def self.extract_stem_text(element)
            asciimath = MathUtil.asciimath_from_stem(element)
            return asciimath if asciimath

            extract_element_text(element)
          end

          def self.extract_span_text(element)
            text = extract_element_text(element)
            return text unless text.strip.empty?

            extract_formatted_text(element)
          end

          def self.extract_name_text(name)
            return name if name.is_a?(String)

            text = SafeAttr.read(name, :text)
            return text.to_s if text.is_a?(String) && !text.strip.empty?

            stems = SafeAttr.read(name, :stem)
            if stems.is_a?(Array) && !stems.empty?
              parts = Array(text).dup
              stems.each_with_index do |s, i|
                stem_text = MathUtil.text_from_stem(s)
                parts.insert(i + 1, stem_text) if stem_text && !stem_text.empty?
              end
              joined = parts.join.strip
              return joined unless joined.empty?
            end

            return Array(text).join if text.is_a?(Array) && !text.empty?

            ""
          end

          def self.extract_bibdata_title(bibdata)
            return nil unless bibdata

            title = bibdata.title
            return nil unless title

            case title
            when String then title
            when Array
              first = title.first
              return nil unless first

              if first.is_a?(String)
                first
              elsif first.is_a?(Lutaml::Model::Serializable)
                Array(first.content).join
              else
                first.to_s
              end
            else title.to_s
            end
          end
        end
      end
    end
  end
end
