# frozen_string_literal: true

module Metanorma
  module Document
    module Presentation
      # Takes a document model and a profile, and returns a presentation
      # model of the same class. The input document is never modified:
      # the engine works on a deep copy, so a
      # profile with no rules yields a model equal to the input.
      class Engine
        attr_reader :profile

        def initialize(profile: Profile.noop)
          @profile = profile
        end

        def call(document)
          model = Marshal.load(Marshal.dump(document))
          profile.rules.each { |rule| rule.call(model) }
          model
        end
      end
    end
  end
end
