require "slack-notifier"

require "slack/notification/version"
require "slack/message"
require "slack/field"
require "slack/author"
require "slack/footer"

module FDE
  module Slack
    module Notification
      class Config
        attr_accessor :webhook
      end

      def self.config
        @@config ||= Config.new
      end

      def self.configure
        yield self.config
      end
    end
  end
end
