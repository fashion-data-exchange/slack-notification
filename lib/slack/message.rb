module FDE
  module Slack
    class Message
      BLUE = '#BDE5F8'.freeze
      GREEN = '#DFF2BF'.freeze
      YELLOW = '#FEEFB3'.freeze
      RED = '#FFBABA'.freeze

      attr_accessor :username,
        :title,
        :author,
        :fields,
        :footer,
        :color

      def initialize(title, fields, author = nil, footer = nil, username = nil)
        @username = username || 'FDE Slack Notifier'
        @title = title
        @author = author
        @fields = fields
        @footer = footer
      end

      def info(channel)
        @color = BLUE
        send(channel)
      end

      def success(channel)
        @color = GREEN
        send(channel)
      end

      def warning(channel)
        @color = YELLOW
        send(channel)
      end

      def error(channel)
        @color = RED
        send(channel)
      end

      def add_field(field)
        @fields << field.to_h
      end

      private

      def send(channel)
        notifier = ::Slack::Notifier.new(
          FDE::Slack::Notification.config.webhook,
          channel: channel,
          username: @username
        )
        notifier.ping message_hash
      end

      def message_hash
        { attachments: [ attachment_hash ] }
      end

      def attachment_hash
        hash = {
          fallback: @title,
          ts: Time.now.to_i,
          color: @color,
          fields: @fields
        }
        hash.merge!(@author.to_h)
        hash.merge!(@footer.to_h)
        hash
      end
    end
  end
end
