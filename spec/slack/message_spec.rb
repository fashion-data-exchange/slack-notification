require "spec_helper"

RSpec.describe FDE::Slack::Message do

  let(:channel) { 'fde-edi' }

  let(:username) { 'FDE Test Slack Notifier' }
  let(:main_title) { 'Test FDE Slack Notification' }

  let(:name) { "William Shakespeare" }
  let(:link) { "https://en.wikipedia.org/wiki/William_Shakespeare" }
  let(:icon) { "https://commons.wikimedia.org/wiki/William_Shakespeare#/media/File:Shakespeare.jpg" }
  let(:author) do
    FDE::Slack::Author.new(name, link, icon)
  end

  let(:title) { "A Test Title" }
  let(:value) { "Something meaningful" }
  let(:field) do
    FDE::Slack::Field.new(title, value, false)
  end

  let(:fields) { [field.to_h] }

  let(:footer_value) { "William Shakespeare" }
  let(:footer) do
    FDE::Slack::Footer.new(title, value)
  end

  context 'with only a title and fields', :vcr do
    subject { described_class.new(main_title, fields) }

    describe '#title' do
      it 'should have a title' do
        expect(subject.title).to eq(main_title)
      end
    end

    describe '#fields' do
      it 'should have fields' do
        expect(subject.fields).to include(field.to_h)
      end
    end

    describe '#deliver' do
      let(:channel) { '#channel' }
      context 'when no level is specified' do
        it 'defaults to info level' do
          expect(subject).to receive(:info).with(channel)
          subject.deliver(channel)
        end
      end

      context 'when message sending throws an error', :focus do
        before do
          allow_any_instance_of(Slack::Notifier).to receive(:ping).and_raise(Slack::Notifier::APIError)
        end

        it 'should handle the error and throw an FDE::Slack::Message::Error' do
          expect { subject.deliver(channel) }.to raise_error(FDE::Slack::Message::Error)
        end
      end
      
      context 'when level is set' do
        context 'to info' do
          it 'sends an info message' do
            expect(subject).to receive(:info).with(channel)
            subject.deliver(channel)
          end
        end

        context 'to success' do
          it 'sends an success message' do
            expect(subject).to receive(:success).with(channel)
            subject.deliver(channel, level: :success)
          end
        end

        context 'to warning' do
          it 'sends an warning message' do
            expect(subject).to receive(:warning).with(channel)
            subject.deliver(channel, level: :warning)
          end
        end

        context 'to error' do
          it 'sends an error message' do
            expect(subject).to receive(:error).with(channel)
            subject.deliver(channel, level: :error)
          end
        end
      end
    end

    describe '#info', :vcr do
      it 'should send a info message' do
        expect(subject.info(channel).first.code).to eq("200")
      end
      it 'should have a blue color' do
        subject.info(channel)
        expect(subject.color).to eq(described_class::BLUE)
      end
    end

    describe '#success', :vcr do
      it 'should send a info message' do
        expect(subject.success(channel).first.code).to eq("200")
      end

      it 'should have a green color' do
        subject.success(channel)
        expect(subject.color).to eq(described_class::GREEN)
      end
    end
  end

  context 'with an author', :vcr do
    subject { described_class.new(main_title, fields, author: author) }

    describe '#error', :vcr do
      it 'should send a info message' do
        expect(subject.error(channel).first.code).to eq("200")
      end

      it 'should have a red color' do
        subject.error(channel)
        expect(subject.color).to eq(described_class::RED)
      end
    end
  end

  context 'with a footer', :vcr do
    subject do
      described_class.new(main_title, fields, author: author, footer: footer)
    end

    describe '#warning', :vcr do
      it 'should send a info message' do
        expect(subject.warning(channel).first.code).to eq("200")
      end
      it 'should have a yellow color' do
        subject.warning(channel)
        expect(subject.color).to eq(described_class::YELLOW)
      end
    end
  end

  describe '#add_field', :vcr do
    subject { described_class.new(main_title, fields) }
    let(:another_title) { "Another Title" }
    let(:another_value) { "Value 1234" }
    let(:another_field) do
      FDE::Slack::Field.new(another_title, another_value)
    end

    it 'should have the predefinded fields' do
      expect(subject.fields).to include(field.to_h)
    end

    it 'should add a new field' do
      subject.add_field(another_field)
      expect(subject.fields).to include(field.to_h)
      expect(subject.fields).to include(another_field.to_h)
    end

    it 'should send this new field' do
      subject.add_field(another_field)
      expect(subject.success(channel).first.code).to eq("200")
    end
  end
end
