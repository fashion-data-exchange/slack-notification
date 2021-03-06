# frozen_string_literal: true

require "net/http"

# Custom HTTP Client to auto-retry once when Slack Rate Limit error is encountered.
# The basis of this code is from https://github.com/stevenosloan/slack-notifier/blob/master/lib/slack-notifier/util/http_client.rb
# The improved APIError code from https://github.com/stevenosloan/slack-notifier/pull/111
# And the rate limit retry is custom
module FDE
  module Slack
    class APIError < StandardError
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def message
        <<-MSG
The slack API returned an error with HTTP Code #{@response.code}
Check the "Handling Errors" section on https://api.slack.com/incoming-webhooks for more information
        MSG
      end
    end

    module Util
      class HTTPClient
        class << self
          def post uri, params
            HTTPClient.new(uri, params).call
          end
        end

        attr_reader :uri, :params, :http_options

        def initialize uri, params
          @uri          = uri
          @http_options = params.delete(:http_options) || {}
          @params       = params
        end

        def call
          http_obj.request(request_obj).tap do |response|
            unless response.is_a?(Net::HTTPSuccess)
              raise FDE::Slack::APIError.new(response)
            end
          end
        end

        private

        def request_obj
          req = Net::HTTP::Post.new uri.request_uri
          req.set_form_data params

          req
        end

        def http_obj
          http = Net::HTTP.new uri.host, uri.port
          http.use_ssl = (uri.scheme == "https")

          http_options.each do |opt, val|
            if http.respond_to? "#{opt}="
              http.send "#{opt}=", val
            else
              warn "Net::HTTP doesn't respond to `#{opt}=`, ignoring that option"
            end
          end

          http
        end
      end
    end
  end
end
