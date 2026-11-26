# frozen_string_literal: true

module Metanorma
  module Document
    module Presentation
      # A profile is an ordered list of rules. A rule is any object
      # responding to #call(model) that edits the presentation model in
      # place. The profile data format (layered base < flavor < taste)
      # is a later slice; this class only carries the ordered rules.
      class Profile
        attr_reader :name, :rules, :settings

        # settings is resolved profile data (see LayeredProfile); rules
        # are the behaviours that act on the model.
        def initialize(name: "noop", rules: [], settings: {})
          @name = name
          @rules = rules.dup.freeze
          @settings = settings.freeze
        end

        # The profile that changes nothing.
        def self.noop
          new
        end

        def noop?
          rules.empty?
        end
      end
    end
  end
end
