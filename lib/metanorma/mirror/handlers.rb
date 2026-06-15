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

      def self.build_node(type, attrs: {}, content: [])
        if content.nil? || content.empty?
          Model::Leaf.new(type: type, attrs: attrs)
        else
          Model::Container.new(type: type, attrs: attrs, content: content)
        end
      end

      def self.build_text(text, marks: [])
        Model::Text.new(text: text, marks: marks)
      end

      def self.build_mark(type, attrs: {})
        Model::Mark.new(type: type, attrs: attrs)
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
        Inline::TextExtractor.extract_name_text(name)
      end

      def self.extract_bibdata_title(bibdata)
        Inline::TextExtractor.extract_bibdata_title(bibdata)
      end
    end
  end
end
