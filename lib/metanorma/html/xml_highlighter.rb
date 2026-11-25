# frozen_string_literal: true

module Metanorma
  module Html
    # Minimal XML syntax highlighting for the reader's sourcecode
    # blocks. Tokenizes tags, attribute names, quoted values, comments
    # and processing instructions on the raw text; everything outside
    # tags passes through escaped. Emits the highlight.js-style
    # classes (nt / na / s / c) the stylesheets color per theme.
    # Zero dependencies.
    module XmlHighlighter
      module_function

      LANGUAGES = /\A(xml|xhtml|html|svg)\z/i

      def highlight(text, lang: nil)
        return escape(text) unless lang.to_s.match?(LANGUAGES)
        return escape(text) if text.nil?

        out = +""
        pos = 0
        while (lt = text.index("<", pos))
          out << escape(text[pos...lt])
          close = tag_end(text, lt)
          if close.nil?
            # Unterminated tag: highlight what is there, no trailing ">".
            out << "&lt;#{highlight_element(text[(lt + 1)..].to_s)}"
            pos = text.length
            break
          end

          out << highlight_tag(text[lt...close])
          pos = close
        end
        out << escape(text[pos..].to_s)
      rescue StandardError
        escape(text.to_s)
      end

      # Index just past the construct opening at +lt+ ("</...>",
      # "<?...?>", "<!--...-->", "<![CDATA[...]]>", "<...>"), quote-
      # aware so ">" inside attribute values does not end the tag.
      # Unterminated constructs run to end of input; nil past it.
      def tag_end(text, lt)
        rest = text[lt..].to_s
        if rest.start_with?("<!--")
          idx = text.index("-->", lt + 4)
          idx ? idx + 3 : text.length
        elsif rest.start_with?("<?")
          idx = text.index("?>", lt + 2)
          idx ? idx + 2 : text.length
        elsif rest.start_with?("<![CDATA[")
          idx = text.index("]]>", lt + 9)
          idx ? idx + 3 : text.length
        else
          quote = nil
          i = lt
          while i < text.length
            ch = text[i]
            if quote
              quote = nil if ch == quote
            elsif ch == '"' || ch == "'"
              quote = ch
            elsif ch == ">"
              return i + 1
            end
            i += 1
          end
          nil
        end
      end

      def highlight_tag(tag)
        inner = tag[1...-1].to_s
        body =
          if inner.start_with?("!--")
            span("c", inner)
          elsif inner.start_with?("?") || inner.start_with?("!")
            span("c", inner)
          else
            highlight_element(inner)
          end
        "&lt;#{body}&gt;"
      end

      def highlight_element(inner)
        closing = inner.start_with?("/") ? "/" : ""
        inner = inner.delete_prefix("/")
        self_closing = inner.end_with?("/") ? "/" : ""
        inner = inner.delete_suffix("/")

        name = inner[/\A[\w:.-]+/]
        rest = name ? inner[name.length..].to_s : inner

        out = closing.dup
        out << span("nt", name) if name
        out << highlight_attrs(rest)
        out << escape(self_closing)
        out
      end

      def highlight_attrs(rest)
        out = +""
        rest.scan(
          /([\w:.-]+)(=)("[^"]*"|'[^']*')|([\w:.-]+)|(\s+)|(.)/m,
        ) do |name, eq, value, bare, ws, other|
          if name
            out << span("na", name) << escape(eq)
            out << span("s", value) if value
          elsif bare
            out << span("na", bare)
          elsif ws
            out << ws
          elsif other
            out << escape(other)
          end
        end
        out
      end

      def span(css_class, content)
        %(<span class="#{css_class}">#{escape(content)}</span>)
      end

      def escape(text)
        text.to_s
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
      end
    end
  end
end
