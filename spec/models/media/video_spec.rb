require 'rails_helper'

describe Media::Video do
  describe 'validations' do
    context 'the url is not a video' do

      subject { Media::Video.create(url: Faker::Internet.url) }

      it "doesn't save the Video" do
        expect(subject).to_not be_valid
      end
    end

  end
end
