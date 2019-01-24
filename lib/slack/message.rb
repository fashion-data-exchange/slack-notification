module FDE
  module Slack
    class Message

      class Error < StandardError; end

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

      def initialize(title, fields, options = {})
        @title = title
        @fields = fields
        if options[:title_link]
          @title_link = options[:title_link]
        end
        if options[:username]
          @username = options[:username] || 'FDE Slack Notifier'
        end
        if options[:author]
          @author = options[:author]
        end
        if options[:footer]
          @footer = options[:footer]
        end
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
        begin 
          notifier.ping message_hash
        rescue Slack::Notifier::APIError
          raise FDE::Slack::Message::Error
        end
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
        hash.merge!(@title_link.to_h)
        hash
      end
    end
  end
end
