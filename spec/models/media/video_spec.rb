require 'rails_helper'

describe Media::Video do
  describe 'validations' do
    context 'the url is not a video' do

      subject { Media::Video.create(url: Faker::Internet.url) }

      it "doesn't save the Video" do
        expect(subject).to_not be_valid
      end
    end

    context 'the url is a video' do

      let(:provider_name) { 'youtube' }
      subject { Media::Video.create(url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ') }

      it 'saves the video' do
        expect(subject).to be_valid
      end

      it 'updates the provider' do
        expect(subject.provider_id).to_not be_nil
        expect(subject.provider_name).to eq(provider_name)
      end

      it 'updates the thumbnail' do
        expect(subject.thumbnail_url).to_not be_nil
      end
    end

  end
end
