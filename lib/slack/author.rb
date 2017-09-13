module FDE
  module Slack
    class Author
      attr_accessor :name, :link, :icon

      def initialize(name, link = nil, icon = nil)
        @name = name
        @link = link
        @icon = icon
      end

      def to_h
        hash = {}
        hash[:author_name] = @name
        hash[:author_link] = @link if @link
        hash[:author_icon] = @icon if @icon
        hash
      end

      alias_method :to_hash, :to_h
    end
  end
end
