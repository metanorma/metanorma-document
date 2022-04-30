# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Type of bibliographic item.
  #
  # The value list complies with the types provided in ISO 690:2021.
  #
  # NOTE: These values represent a strict superset to BibTeX
  # publication types, and therefore any BibTeX type value can be
  # mapped to these values. Some values here do not have a corresponding
  # entry in BibTeX, for instance, "standard" and "website".
  #
  # NOTE: While the value of "electronicResource" exists, the
  # distinction between offline and online resources
  # should be made through medium (electronic vs physical).
  class BibItemType < Core::Node::Enum
    # An article from a journal or magazine.
    ARTICLE = new("article")

    # A monograph.
    BOOK = new("book")

    # A booklet or pamphlet. The distinction between book and booklet is not made frequently.
    BOOKLET = new("booklet")

    # A manual.
    MANUAL = new("manual")

    # A conference proceedings.
    PROCEEDINGS = new("proceedings")

    # A presentation given in a formal meeting.
    PRESENTATION = new("presentation")

    # A dissertation given in an academic institution, as a summation of research.
    THESIS = new("thesis")

    # A technical report.
    TECH_REPORT = new("techReport")

    # A standard, a document issued by a Standards Defining Organization.
    STANDARD = new("standard")

    # An intellectual creation which has not been published, e.g. a manuscript.
    #
    # NOTE: Properly this does not represent a distinct bibliographic type, and it
    # should be avoided in favour of using the `status` element of `BibliographicItem`.
    UNPUBLISHED = new("unpublished")

    # A map or other cartographic resource.
    MAP = new("map")

    # A resource avaiulable in digital form.
    #
    # NOTE: The overloaded type `electronicResource` should be avoided where possible, particularly if the
    # resource corresponds closely to a paper bibliographic type, such as `book` or `article`.
    # Specialisations of `electronicResource` include `dataset`, `webResource`, `website`,
    # `socialMedia`, and `software`.
    ELECTRONIC_RESOURCE = new("electronicResource")

    # An audiovisual resource. Is a superclass of other types such as `video` and `music`.
    AUDIOVISUAL = new("audiovisual")

    # A film.
    FILM = new("film")

    # A video.
    VIDEO = new("video")

    # A broadcast made through mass media, including radio and television.
    BROADCAST = new("broadcast")

    # A graphic work, a work with two-dimensional or three-dimensional content.
    GRAPHIC_WORK = new("graphicWork")

    # A musical work. Includes both notated music and music performances:
    # The two are differentiated through `BibliographicItem/medium/content` as
    # "notated music" vs "performed music".
    MUSIC = new("music")

    # A patent.
    PATENT = new("patent")

    # A (typically untitled) part of a book. May be a chapter (or section, etc.) and/or a range of pages.
    IN_BOOK = new("inBook")

    # A part of a book having its own title, and typically having distinct authorship..
    IN_COLLECTION = new("inCollection")

    # An article in a conference proceedings.
    IN_PROCEEDINGS = new("inProceedings")

    # A journal or periodical publication.
    JOURNAL = new("journal")

    # A human-readable or consumable web resource,
    # a single item accessible online via a web browser,
    # which is not composed of components all of which can be accessed in the same
    # way. Includes media files, as well as individual web pages.
    WEB_RESOURCE = new("webResource")

    # A collection of web resources, presented under the same URL domain and by the same
    # (individual or corporate) authorship.
    WEBSITE = new("website")

    # An electronic dataset, a collection of data that is not meant to be human-readable,
    # and which is typically only machine readable.
    DATASET = new("dataset")

    # A instance of a resource curated and preserved in an archive, which mediates any access
    # to it. Typically it is physical, unique, and unpublished.
    #
    # NOTE: The content of the resource may be published separately,
    # but that makes it a distinct bibliographic item, as access to it is no longer mediated
    # through the archive.
    ARCHIVAL = new("archival")

    # Computer executable code, not itself human-readable text (though it may generate such text).
    SOFTWARE = new("software")

    # One or more resources within a collection that is typically collectively authored by member users.
    # Includes blog posts, forum posts, social media posts, tweets. Is usually a `webResource`,
    # but not always (e.g. blogs on WeChat are only accessible within the WeChat app.)
    SOCIAL_MEDIA = new("socialMedia")

    # A single communication intended for multiple persons, and publicly accessible. May be
    # electronic (e.g. Facebook status update) or voice (e.g. evacuation alert), but is typically not
    # print.
    ALERT = new("alert")

    # A single communication intended for a restricted number of authorised persons (typically one).
    # May be electronic (e.g. Twitter direct message, email) or voice (e.g. a remark made to someone,
    # typically cited as "personal communication").
    MESSAGE = new("message")

    # An exchange of messages between two or more persons. May be electronic (e.g. web chat)
    # or voice (e.g. phone call).
    CONVERSATION = new("conversation")

    # Bibliographic type not adequately described in the foregoing.
    MISC = new("misc")
  end
end; end; end
