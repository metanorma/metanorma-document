# frozen_string_literal: true

class String
  # Since we represent text nodes plainly as Strings, we want
  # a way to convert them back to Nokogiri. We could either
  # dynamically check for types, but I think this way is way
  # cleaner.
  def to_ng(ng_document)
    Nokogiri::XML::Text.new(self, ng_document)
  end
end
