require "spec_helper"

RSpec.describe FDE::Slack::Author do

  let(:name) { "William Shakespeare" }
  let(:link) { "https://en.wikipedia.org/wiki/William_Shakespeare" }
  let(:icon) { "https://commons.wikimedia.org/wiki/William_Shakespeare#/media/File:Shakespeare.jpg" }

  subject { described_class.new(name, link) }

  describe '#to_h' do
    let(:hash_without_icon) do
      {
        author_name: name,
        author_link: link
      }
    end

    let(:hash_fullmonty) do
      {
        author_name: name,
        author_link: link,
        author_icon: icon
      }
    end

    it 'should return a hash' do
      expect(subject.to_h).to eq(hash_without_icon)
    end

    it 'should have an alias method #to_hash' do
      expect(subject.to_h).to eq(subject.to_hash)
    end

    context 'with icon' do
      subject { described_class.new(name, link, icon) }

      it 'should have an icon link in the hash if an icon is given' do
        expect(subject.to_h).to eq(hash_fullmonty)
      end
    end
  end

end
