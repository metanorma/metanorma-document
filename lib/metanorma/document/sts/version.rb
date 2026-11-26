# frozen_string_literal: true

module Metanorma
  module Document
    module Sts
      # Engine version marker: reports the gem version. Flavor facades
      # report their own gem versions in rendered output via the
      # profile's identity.version_string.
      VERSION = Metanorma::Document::VERSION
      Version = VERSION
    end
  end
end
