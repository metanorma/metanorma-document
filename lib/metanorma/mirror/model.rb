# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      autoload :Node, "#{__dir__}/model/node"
      autoload :Container, "#{__dir__}/model/container"
      autoload :Leaf, "#{__dir__}/model/leaf"
      autoload :Text, "#{__dir__}/model/text"
      autoload :SoftBreak, "#{__dir__}/model/soft_break"
      autoload :Mark, "#{__dir__}/model/mark"
      autoload :Guide, "#{__dir__}/model/guide"
      autoload :Factory, "#{__dir__}/model/factory"
    end
  end
end
