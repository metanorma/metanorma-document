# frozen_string_literal: true

module Metanorma
  module Document
    module Sts
      # HTML rendering for NISO STS XML (Liquid-based; see
      # html_renderer/ruby.rb). Branding comes from the profile's
      # identity.
      module HtmlRenderer
        autoload :Ruby, "#{__dir__}/html_renderer/ruby"

        module_function

        # @param sts_xml [Sts::NisoSts::Standard, String] model or XML.
        # @param profile [Profile, Symbol, nil] rendering identity.
        def render(sts_xml, profile: nil, **)
          renderer = profile.nil? ? Ruby : Profiles.resolve(profile).resolve(Ruby)
          renderer.new(profile: profile).render(sts_xml, **)
        end
      end
    end
  end
end
