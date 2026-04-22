# frozen_string_literal: true

module Metanorma
  module BasicDocument
    module IdElements
      autoload :AltSource, "#{__dir__}/id_elements/alt_source"
      autoload :Audio, "#{__dir__}/id_elements/audio"
      autoload :Bookmark, "#{__dir__}/id_elements/bookmark"
      autoload :IdElement, "#{__dir__}/id_elements/id_element"
      autoload :Image, "#{__dir__}/id_elements/image"
      autoload :Media, "#{__dir__}/id_elements/media"
      autoload :MediaType, "#{__dir__}/id_elements/media_type"
      autoload :Video, "#{__dir__}/id_elements/video"
    end
  end
end
