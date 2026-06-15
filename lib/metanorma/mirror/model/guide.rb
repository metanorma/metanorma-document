# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      class Guide
        attr_reader :content, :meta, :title

        def initialize(content:, meta: {}, title: nil)
          @content = content
          @meta = meta
          @title = title
        end

        def to_h
          h = {}
          h["content"] = @content.is_a?(Container) ? @content.to_h : @content
          h["meta"] = @meta unless @meta.nil? || @meta.empty?
          h["title"] = @title if @title
          h
        end
      end
    end
  end
end
