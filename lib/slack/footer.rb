module FDE
  module Slack
    class Footer
      attr_accessor :value, :icon

      def initialize(value, icon = nil)
        @value = value
        @icon = icon
      end

      def to_h
        hash = {}
        hash[:footer] = @value
        hash[:footer_icon] = @icon if @icon
        hash
      end

      alias_method :to_hash, :to_h
    end
  end
end
