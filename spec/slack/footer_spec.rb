require "spec_helper"

RSpec.describe FDE::Slack::Footer do

  let(:value) { "William Shakespeare" }
  let(:icon) { "https://commons.wikimedia.org/wiki/William_Shakespeare#/media/File:Shakespeare.jpg" }

  subject { described_class.new(value) }

  describe '#to_h' do
    let(:hash_without_icon) do
      {
        footer: value
      }
    end

    let(:hash_fullmonty) do
      {
        footer: value,
        footer_icon: icon
      }
    end

    it 'should return a hash' do
      expect(subject.to_h).to eq(hash_without_icon)
    end

    it 'should have an alias method #to_hash' do
      expect(subject.to_h).to eq(subject.to_hash)
    end

    context 'with icon' do
      subject { described_class.new(value, icon) }

      it 'should have an icon link in the hash if an icon is given' do
        expect(subject.to_h).to eq(hash_fullmonty)
      end
    end
  end


end
