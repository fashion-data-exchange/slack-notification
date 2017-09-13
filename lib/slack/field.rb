module FDE
  module Slack
    class Field
      attr_accessor :title,
        :value,
        :short

      def initialize(title, value, short = false)
        @title = title
        @value = value
        @short = short
      end

      def to_h
        {
          title: @title,
          value: @value,
          short: @short
        }
      end

      alias_method :to_hash, :to_h
    end
  end
end
