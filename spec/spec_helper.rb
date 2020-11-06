require 'dotenv'
Dotenv.load('.test.env')

require 'bundler/setup'
require 'vcr'
require 'pry'
require "slack/notification"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.filter_run :focus => true
  config.filter_run_excluding :ignore => true
  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

end

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassetts"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = true
  config.default_cassette_options = {
    match_requests_on: [:method, :path]
  }
end

FDE::Slack::Notification.configure do |config|
  config.webhook = ENV.fetch('FDE_SLACK_WEBHOOK_URL')
end
