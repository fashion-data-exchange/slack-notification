# frozen_string_literal: true

require "spec_helper"

RSpec.describe FDE::Slack::Util::HTTPClient do
  describe "::post" do
    it "initializes Util::HTTPClient with the given uri and params then calls" do
      http_post_double = instance_double("FDE::Slack::Util::HTTPClient")

      expect(described_class)
        .to receive(:new).with("uri", "params")
                         .and_return(http_post_double)
      expect(http_post_double).to receive(:call)

      described_class.post "uri", "params"
    end

    # http_post is really tested in the integration spec,
    # where the internals are run through
  end

  describe "#initialize" do
    it "allows setting of options for Net::HTTP" do
      net_http_double = instance_double("Net::HTTP")
      http_client     = described_class.new URI.parse("http://example.com"),
                                            http_options: { open_timeout: 5 }

      allow(Net::HTTP).to receive(:new).and_return(net_http_double)
      allow(net_http_double).to receive(:use_ssl=)
      allow(net_http_double).to receive(:request).with(anything) do
        Net::HTTPOK.new("GET", "200", "OK")
      end

      expect(net_http_double).to receive(:open_timeout=).with(5)

      http_client.call
    end
  end

  describe "#call" do
    context 'when being rate limited' do
      it 'raises an error when the response is unsuccessful' do
        net_http_double = instance_double("Net::HTTP")
        http_client = described_class.new URI.parse("http://example.com"), {}
        bad_request = Net::HTTPBadRequest.new("GET", "429", "nothing")
        allow(bad_request).to receive(:body).and_return("")
        bad_request.header["Retry-After"] = "15"

        allow(Net::HTTP).to receive(:new).and_return(net_http_double)
        allow(net_http_double).to receive(:use_ssl=)
        allow(net_http_double).to receive(:request).with(anything) do
          bad_request
        end

        expect { http_client.call }.to raise_error(FDE::Slack::APIError,
                                                 /HTTP Code 429/)
      end
    end

    it "raises an error when the response is unsuccessful" do
      net_http_double = instance_double("Net::HTTP")
      http_client = described_class.new URI.parse("http://example.com"), {}
      bad_request = Net::HTTPBadRequest.new("GET", "400", "Bad Request")

      allow(bad_request).to receive(:body).and_return("something_bad")
      allow(Net::HTTP).to receive(:new).and_return(net_http_double)
      allow(net_http_double).to receive(:use_ssl=)
      allow(net_http_double).to receive(:request).with(anything) do
        bad_request
      end

      expect { http_client.call }.to raise_error(FDE::Slack::APIError,
                                                 /HTTP Code 400/)
    end
  end

end
