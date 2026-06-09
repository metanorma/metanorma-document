# frozen_string_literal: true

module Metanorma
  module Mirror
    module Handlers
      autoload :Paragraph, "#{__dir__}/handlers/paragraph"
      autoload :Section, "#{__dir__}/handlers/section"
      autoload :List, "#{__dir__}/handlers/list"
      autoload :Table, "#{__dir__}/handlers/table"
      autoload :Figure, "#{__dir__}/handlers/figure"
      autoload :Sourcecode, "#{__dir__}/handlers/sourcecode"
      autoload :Admonition, "#{__dir__}/handlers/admonition"
      autoload :Formula, "#{__dir__}/handlers/formula"
      autoload :Example, "#{__dir__}/handlers/example"
      autoload :Note, "#{__dir__}/handlers/note"
      autoload :Quote, "#{__dir__}/handlers/quote"
      autoload :Review, "#{__dir__}/handlers/review"
      autoload :Inline, "#{__dir__}/handlers/inline"
      autoload :Structural, "#{__dir__}/handlers/structural"
      autoload :Term, "#{__dir__}/handlers/term"

      COMMON_ATTRS = %i[id semx_id].freeze

      def self.build_node(type, attrs: {}, content: [], marks: [])
        h = { "type" => type }
        h["attrs"] = attrs.transform_keys(&:to_s) unless attrs.nil? || attrs.empty?
        h["marks"] = marks unless marks.nil? || marks.empty?
        h["content"] = content unless content.nil? || content.empty?
        h
      end

      def self.build_text(text, marks: [])
        h = { "type" => "text", "text" => text.to_s }
        h["marks"] = marks unless marks.nil? || marks.empty?
        h
      end

      def self.build_mark(type, attrs: {})
        h = { "type" => type }
        h["attrs"] = attrs.transform_keys(&:to_s) unless attrs.nil? || attrs.empty?
        h
      end

      def self.extract_attrs(element, extra_attrs: {})
        attrs = {}
        COMMON_ATTRS.each do |attr|
          attrs[attr] = SafeAttr.read(element, attr)
        end
        extra_attrs.each do |attr, source_attr|
          attrs[attr] = SafeAttr.read(element, source_attr || attr)
        end
        attrs.compact
      end

      def self.extract_name_text(name)
        return name if name.is_a?(String)

        text = SafeAttr.read(name, :text)
        return text.to_s if text.is_a?(String) && !text.strip.empty?

        stems = SafeAttr.read(name, :stem)
        if stems.is_a?(Array) && !stems.empty?
          parts = Array(text).dup
          stems.each_with_index do |s, i|
            stem_text = extract_stem_text(s)
            parts.insert(i + 1, stem_text) if stem_text
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

      def self.extract_stem_text(stem)
        math = SafeAttr.read(stem, :math)
        mathml_from_math(math) if math
      end

      def self.mathml_from_math(math)
        xml = math.is_a?(Array) ? math.map(&:to_xml).join : math.to_xml
        xml.sub(/\A<\?xml[^?]*\?>\s?/, "")
      end
    end
  end
end
