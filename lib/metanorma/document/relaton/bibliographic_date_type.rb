# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Indicates type of date within a bibliographic lifecycle.
  #
  # NOTE: Typically only the `published` date is of interest.
  class BibliographicDateType < Core::Node::Enum
    # The date on which the document was published (distributed by the publisher).
    PUBLISHED = new("published")

    # Date a document was last accessed by the compiler of the bibliographic record;
    # routinely used for online publications.
    #
    # NOTE: Unlike in <<iso690>>, no distinction is made between
    # "viewed" and "accessed" based on whether the resource is human-readable or
    # machine-readable.)
    ACCESSED = new("accessed")

    # The date on which the first version of the document was created.
    CREATED = new("created")

    # The date on which the document takes effect. Applies to normative documents.
    IMPLEMENTED = new("implemented")

    # The date on which the document was obsoleted/revoked.
    OBSOLETED = new("obsoleted")

    # The date on which the document was reviewed and approved by the issuing authority.
    CONFIRMED = new("confirmed")

    # The date on which the current version of the document was updated.
    UPDATED = new("updated")

    # The date on which the document was issued (authorised for publication by the issuing authority).
    # Is typically differentiated from `published` for normative documents, such as
    # standards and legislation.
    ISSUED = new("issued")

    # The date on which the document was broadcast.
    TRANSMITTED = new("transmitted")

    # The date on which the document physically copied, or recreated without any substantial
    # change in content (allowing for change in medium).
    COPIED = new("copied")

    # The date on which the document was last renewed or reprinted without any changes in content.
    UNCHANGED = new("unchanged")

    # The date on which the unpublished document was last circulated
    # officially as a preprint. For standards, this is associated
    # with the latest transition to a formally defined preparation
    # stage, such as Working Draft or Committee Draft.
    CIRCULATED = new("circulated")

    # The date on which a document adapted for a new purpose or audience, with some change
    # in content (includes translation).
    ADAPTED = new("adapted")

    # The date on which a formal process for approval of a document was initiated.
    # Typically applies to standards documents in draft.
    VOTE_STARTED = new("voteStarted")

    # The date on which a formal process for approval of a document was closed.
    # Typically applies to standards documents in draft.
    VOTE_ENDED = new("voteEnded")

    # The date on which the existence of a document is made public.
    # Applies whether the resource has already been created or not, and whether it is to be
    # published or not.
    ANNOUNCED = new("announced")
  end
end; end; end
