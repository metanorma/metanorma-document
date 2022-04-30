# frozen_string_literal: true

module Metanorma; module Document; module IsoDocument
  # Stage-level code in the International Harmonized Stage Codes
  # used by ISO/IEC for their documents.
  #
  # NOTE: See https://www.iso.org/stage-codes.html
  class IsoDocumentStageCodes < Core::Node::Enum
    # Preliminary.
    CODE_00 = new("00")

    # Proposal.
    CODE_10 = new("10")

    # Preparatory.
    CODE_20 = new("20")

    # Committee.
    CODE_30 = new("30")

    # Enquiry.
    CODE_40 = new("40")

    # Approval.
    CODE_50 = new("50")

    # Publication.
    CODE_60 = new("60")

    # Review.
    CODE_90 = new("90")

    # Withdrawal.
    CODE_95 = new("95")
  end
end; end; end
