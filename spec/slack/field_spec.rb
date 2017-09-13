require "spec_helper"

RSpec.describe FDE::Slack::Field do

  let(:title) { "A title" }
  let(:value) { "Some meaningful value" }
  let(:short) { true }

  subject { described_class.new(title, value, short) }

  describe '#to_h' do
    let(:hash) do
      {
        title: title,
        value: value,
        short: short
      }
    end

    it 'should return the field as hash' do
      expect(subject.to_h).to eq(hash)
    end

    it 'should have a alias_method #to_hash' do
      expect(subject.to_hash).to eq(subject.to_h)
    end
  end

end
