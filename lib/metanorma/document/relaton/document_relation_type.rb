# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Type of the relationship between a main document (described in `BibliographicItem`)
  # and a target document.
  class DocumentRelationType < Core::Node::Enum
    # The main document contains the target document. Inverse of `includedIn` relation.
    INCLUDES = new("includes")

    # The main document is a part (component) of the
    # target document (host document); for example, chapter vs book, paper vs journal or
    # proceedings, record track vs record. In general, text-based resources have components
    # that can be considered a
    # different kind of resource; components of non-textual resources are considered
    # to be of the same type as their host. The main and target documents have distinct
    # authorship and metadata.
    INCLUDED_IN = new("includedIn")

    # The main document is a part of a multi-part target document. Inverse of `partOf` relation.
    HAS_PART = new("hasPart")

    # The main document is a multi-part document, and the target document is one of those parts.
    # This relation
    # is equivalent to `includedIn`, but is specific to multi-part textual documents.
    # The main document and the target document are not considered to have distinct authorship
    # and metadata, and are unerstood to be of the same type.
    #
    # [example]
    # ISO 639 refers to the ISO standard for language names; it has three parts
    # ISO 639-1 (two-letter codes), ISO 639-2 (three-letter codes for major languages),
    # and ISO 639-3 (three-letter codes for all natural languages).
    PART_OF = new("partOf")

    # The main document results from a merger of earlier target documents. Inverse of `mergedInto`
    # relation.
    MERGES = new("merges")

    # The main document is one of the documents merged into the later target document.
    MERGED_INTO = new("mergedInto")

    # The main document is split off from an earlier target document. Inverse of `splitInto` relation.
    SPLITS = new("splits")

    # The main document was split into several later target documents.
    SPLIT_INTO = new("splitInto")

    # The main document is a generic reference
    # to a bibliographic item, and the target document is a more specific reference to that
    # item; for example, a specific edition, version, format, or copy of the main document.
    # Inverse of `hasInstance` relation. This is a cover-all for the
    # more specific relations `exemplarOf`, `manifestationOf`, and `expressionOf`.
    #
    # [example]
    # This is used to represent the relation bewteen generic ISO standards,
    # and references to a particular edition of a standard, such as ISO 690 vs
    # ISO 690:2010.
    INSTANCE_OF = new("instanceOf")

    # The main document is a more specific reference to the bibliographic item, and
    # the target document is a more generic reference.
    HAS_INSTANCE = new("hasInstance")

    # The main document is a single physical instance of the bibliographic item,
    # which is more generically referred to in the target document.
    # This corresponds to _Item_ in the Functional Requirements for Bibliographic Records (FRBR) model.
    # Inverse of `hasExemplar` relation.
    EXEMPLAR_OF = new("exemplarOf")

    # The main document is a more generic reference to the bibliographic item, of which
    # the target document is a single physical instance. The main document may be a
    # _Work_, _Expression_ or _Manifestation_ under the Functional Requirements for Bibliographic Records
    # (FRBR) model.
    HAS_EXEMPLAR = new("hasExemplar")

    # The main document is an embodiment in a particular medium of the content of a bibliographic item.
    # which is more generically referred to in the target document.
    # This corresponds to _Manifestation_ in the Functional Requirements for Bibliographic Records (FRBR)
    # model.
    # Inverse of `hasManifestation` relation. Includes the more specific relations `reproductionOf` and
    # `reprintOf`.
    MANIFESTATION_OF = new("manifestationOf")

    # The main document is a more generic reference to the bibliographic item, of which
    # the target document is an embodiment in a particular medium. The main document may be a
    # _Work_ or _Expression_ under the Functional Requirements for Bibliographic Records (FRBR) model.
    HAS_MANIFESTATION = new("hasManifestation")

    # The main document presents the same content as the target document, and the main document
    # has been created to reproduce the target document faithfully. The main and target document are not
    # necessarily
    # in the same medium. Inverse of `hasReproduction` relation. Includes the more specific relation
    # `reprintOf`.
    REPRODUCTION_OF = new("reproductionOf")

    # The main document presents the same content as the target document, and the target document
    # has been created to reproduce the main document faithfully. The main and target document are not
    # necessarily
    # in the same medium.
    HAS_REPRODUCTION = new("hasReproduction")

    # The main document presents the same content as the target document, and the main document
    # has been created to reproduce the target document faithfully. The main and target document are both
    # print publications. Inverse of `hasReprint` relation.
    REPRINT_OF = new("reprintOf")

    # The main document presents the same content as the target document, and the target document
    # has been created to reproduce the main document faithfully. The main and target document are both
    # print publications.
    HAS_REPRINT = new("hasReprint")

    # The main document is a particular realisation of the intellectual or artistic content of the
    # bibliographic item, which is more generically referred to in the target document.
    # This corresponds to _Expression_ in the Functional Requirements for Bibliographic Records (FRBR)
    # model.
    # Inverse of `hasExpression` relation.
    EXPRESSION_OF = new("expressionOf")

    # The main document is a more generic reference to the bibliographic item, whose intellectual or
    # artistic content
    # the target document realises. The main document may be a
    # _Work_ under the Functional Requirements for Bibliographic Records (FRBR) model.
    HAS_EXPRESSION = new("hasExpression")

    # The main document is a translation of the target document. Inverse of `hasTranslation` relation.
    TRANSLATED_FROM = new("translatedFrom")

    # The main document is translated as the target document.
    HAS_TRANSLATION = new("hasTranslation")

    # The main document has the same intellectual or artistic content as the target document, and the main
    # document has been created to realise that content through different resources than the target
    # document.
    # Is typically understood
    # to involve the realisation of a musical work with different instruments than the original. Inverse
    # of
    # `hasArrangement` relation.
    ARRANGEMENT_OF = new("arrangementOf")

    # The main document has the same intellectual or artistic content as the target document, and the
    # target
    # document has been created to realise that content through different resources than the main
    # document.
    # Is typically understood
    # to involve the realisation of a musical work with different instruments than the original.
    HAS_ARRANGEMENT = new("hasArrangement")

    # The main document presents a subset of the intellectual or artistic content of the target document,
    # but is still intended as a complete work, presenting a shortened version of the original.
    # Inverse of `hasAbridgement` relation.
    ABRIDGEMENT_OF = new("abridgementOf")

    # The main document has a target document which presents a subset of its intellectual or artistic
    # content,
    # but which is still intended as a complete work, presenting a shortened version of the original.
    HAS_ABRIDGEMENT = new("hasAbridgement")

    # The main document incorporates part or all of the target document, and enhances it with
    # explanatory commentary. Inverse of `hasAnnotation` relation.
    ANNOTATION_OF = new("annotationOf")

    # The main document has a target document which incorporates part or all of it, and which
    # enhances it with explanatory commentary.
    HAS_ANNOTATION = new("hasAnnotation")

    # The main document is a specific pre-publication version of the work represented
    # by the target document (whether the target document published or pre-published).
    # Inverse of `hasDraft` relation.
    DRAFT_OF = new("draftOf")

    # The main document is a generic reference
    # to a work (whether published or pre-published), and the target document
    # is a specific pre-publication version of the work. Is used to
    # collect information about different drafts of a work, and gateway stages of standards,
    # in the one record.
    HAS_DRAFT = new("hasDraft")

    # The main document is a specific published version of the work represented
    # by the target document. Inverse of `hasEdition` relation.
    EDITION_OF = new("editionOf")

    # The main document is a generic reference to a work, and the target document
    # is a specific published version of the work.
    HAS_EDITION = new("hasEdition")

    # The main document is an update of the target document. Unlike the `obsoletes` relation,
    # the target document may still remain valid after the main document appears.
    # (However by default in the standards world, it does not.) Inverse of `updatedBy` relation.
    UPDATES = new("updates")

    # The main document is updated by the target document. Unlike the `obsoletedBy` relation,
    # the main document may still remain valid after the target document appears.
    # (However by default in the standards world, it does not.)
    UPDATED_BY = new("updatedBy")

    # The main document is derived from the target document, depending on it for at least some
    # of its content. Inverse of `derives` relation.
    DERIVED_FROM = new("derivedFrom")

    # The main document is the original work from which the target document is derived.
    DERIVES = new("derives")

    # The main document includes a description of the target document. Inverse of `describedBy` relation.
    # Includes the more specific `catalogues` relation.
    DESCRIBES = new("describes")

    # The main document is described by the target document.
    DESCRIBED_BY = new("describedBy")

    # The main document includes a bibliographic record of the target document. Inverse of `cataloguedBy`
    # relation.
    CATALOGUES = new("catalogues")

    # The main document has its bibliographic record included in the target document.
    CATALOGUED_BY = new("cataloguedBy")

    # The main document has ceased fulfilling some function, and the target document has assumed that
    # function in its stead. Typically applies when the main document is a periodical publication
    # which has ceased publication, and the target document is a new periodical publication,
    # designated as the continuation of the main document. Inverse of `successorOf` relation.
    HAS_SUCCESSOR = new("hasSuccessor")

    # The main document has assumed the function of the target dcoument, which has ceased fulfilling
    # that function. Typically applies when the target document is a periodical publication
    # which has ceased publication, and the main document is a new periodical publication,
    # designated as the continuation of the target document.
    SUCCESSOR_OF = new("successorOf")

    # The main document has its intellectual or artistic content derived from the target document,
    # and has modified it to match the requirements of a different medium. Is typically applied to
    # textual originals, whereas `arrangementOf` is typically applied to musical originals. Inverse of
    # `hasAdaptation` relation.
    ADAPTED_FROM = new("adaptedFrom")

    # The main document has been modified in the target document, to present its content matching
    # the requirements of a different medium. Is typically applied to
    # textual originals, whereas `hasArrangement` is typically applied to musical originals.
    HAS_ADAPTATION = new("hasAdaptation")

    # The main document has its content derived from the target document, and has been adopted in response
    # to it.
    # Typically it is a national standard body's counterpart to an international
    # standard. Inverse of `adoptedAs` relation. Includes more specific relations `identical`,
    # `equivalent`,
    # and `nonequivalent`.
    ADOPTED_FROM = new("adoptedFrom")

    # The main document has a counterpart in the target document, which derives it content from the main
    # document,
    # and has been adopted in response to the main document.
    # Typically it is an international standard which has had national standard bodies formulate
    # a local counterpart.
    ADOPTED_AS = new("adoptedAs")

    # The main document is an evaluation of the target document. Inverse of `hasReview`.
    REVIEW_OF = new("reviewOf")

    # The main document is evaluated in the target document.
    HAS_REVIEW = new("hasReview")

    # The main document provides explanatory commentary on the target document. Unlike `annotationOf`,
    # the main document does not incorporate the complete text of the target document, and so
    # cannot be read independently of the original. Inverse of `hasCommentary`.
    COMMENTARY_OF = new("commentaryOf")

    # The main document is given explanatory commentary in the target document. Unlike `hasAnnotation`,
    # the target document does not incorporate the complete text of the main document, and so
    # cannot be read independently of the original.
    HAS_COMMENTARY = new("hasCommentary")

    # The main document corresponds
    # to the target document, is equivalent to it in force and scope,
    # and is identical to it in content. This is typically a subclass of the `adoptedFrom` relation.
    IDENTICAL = new("identical")

    # The main document corresponds
    # to the target document, but is not equivalent to it in force and scope.
    # This is typically a subclass of the `adoptedFrom` relation.
    NONEQUIVALENT = new("nonequivalent")

    # The main document corresponds
    # to the target document, and is equivalent to it in force and scope,
    # though not in content. This is typically a subclass of the `adoptedFrom` relation.
    EQUIVALENT = new("equivalent")

    # The main document is related to the target document in an otherwise unspecified fashion.
    RELATED = new("related")

    # The main document is complementary to the target document, and provides additional
    # or contextual information to help understand the target document. Inverse of `complementOf`
    # relation.
    COMPLEMENTS = new("complements")

    # The main document has additional or contextual information provided in the the target document,
    # to help understand the main document. The target document is complementary to the main document.
    COMPLEMENT_OF = new("complementOf")

    # The main document supersedes the target document, which is no longer valid (unlike the `updates`
    # relation,
    # which leaves the validity of the target document open). Inverse of `obsoletedBy` relation.
    OBSOLETES = new("obsoletes")

    # The main document is superseded by the target document, and is no longer valid (unlike the
    # `updatedBy` relation,
    # which leaves the validity of the main document open).
    OBSOLETED_BY = new("obsoletedBy")

    # The main document references the target document. Inverse of `isCitedIn` relation.
    CITES = new("cites")

    # The main document is referenced in the target document.
    IS_CITED_IN = new("isCitedIn")
  end
end; end; end
