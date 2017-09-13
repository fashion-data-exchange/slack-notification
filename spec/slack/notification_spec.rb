require "spec_helper"

RSpec.describe FDE::Slack::Notification do
  it "has a version number" do
    expect(FDE::Slack::Notification::VERSION).not_to be nil
  end

  describe 'configuration' do
    it 'is of Type FDE::S3Client::Config' do
      expect(subject.config).to be_a(FDE::Slack::Notification::Config)
    end

    it 'yields the config block' do
      expect do |b|
        subject.configure(&b)
      end.to yield_with_args
    end
  end
end
