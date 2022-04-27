# frozen_string_literal: true

module Metanorma; module Document; module Devel; module ClassGen
  # Utility functions for ClassGen classes/modules
  module Util
    # Convertor functions for various types of letter cases:
    # - pc: PascalCase
    # - sc: snake_case
    # - dc: dromedaryCase
    # - cc: CONST_CASE
    def pc2sc(sym)
      sym.to_s.gsub(/([A-Z])/) { "_#{$1.downcase}" }.sub(/\A_/, "").to_sym
    end

    def sc2pc(sym)
      sym.to_s.gsub(/(?:_|\A)([a-z])/) { $1.upcase }.to_sym
    end

    alias dc2sc pc2sc

    def dc2cc(sym)
      dc2sc(sym).to_s.upcase.to_sym
    end
  end
end; end; end; end
