module FDE
  module Slack
    class Message

      class Error < StandardError; end

      BLUE = '#BDE5F8'.freeze
      GREEN = '#DFF2BF'.freeze
      YELLOW = '#FEEFB3'.freeze
      RED = '#FFBABA'.freeze

      RETRY_LIMIT = 3
      TOO_MANY_REQUESTS_STATUS_CODE = "429"


      attr_accessor :username,
        :title,
        :author,
        :fields,
        :footer,
        :color

      attr_reader :retries

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

        @retries = 0
      end

      def deliver(channel, level: :info)
        send(level, channel)
      end

      def info(channel)
        @color = BLUE
        send_message(channel)
      end

      def success(channel)
        @color = GREEN
        send_message(channel)
      end

      def warning(channel)
        @color = YELLOW
        send_message(channel)
      end

      def error(channel)
        @color = RED
        send_message(channel)
      end

      def add_field(field)
        @fields << field.to_h
      end

      private

      def send_message(channel)
        notifier = ::Slack::Notifier.new(
          FDE::Slack::Notification.config.webhook,
          channel: channel,
          username: @username
        ) do
          # configure Slack Notifier gem to use our custom HTTPClient
          # see https://github.com/stevenosloan/slack-notifier#custom-http-client
          http_client FDE::Slack::Util::HTTPClient
        end

        begin 
          notifier.ping message_hash
        rescue FDE::Slack::APIError => api_error
          # TooManyRequests, Slack Rate Limit
          if api_error.response.code == TOO_MANY_REQUESTS_STATUS_CODE && @retries < RETRY_LIMIT
            timeout = api_error.response.header['Retry-After'].to_i
            sleep(timeout) if timeout
            @retries += 1
            retry
          end
          raise api_error, message_hash: message_hash

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
