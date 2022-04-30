# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # The copyright status of a bibliographic item.
  class CopyrightAssociation < Core::Node
    include Core::Node::Custom

    register_element do
      # The copyright date of the bibliographic item.
      node :from, DateTime

      # The date when the copyright of the bibliographic item expires.
      nodes :to, DateTime

      # The copyright owner for the bibliographic item.
      nodes :owner, Contributor

      # The extent of the bibliographic item, or contexts of use, for which this
      # assertion of copyright applies. For example, this description may only apply
      # to the preface of a book.
      nodes :scope, String
    end
  end
end; end; end
