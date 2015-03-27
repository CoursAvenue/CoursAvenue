require 'rails_helper'

RSpec.describe Admin::ImagesController, type: :controller do
  include ActionDispatch::TestProcess
  include Devise::TestHelpers

  let!(:super_admin) { FactoryGirl.create(:super_admin) }

  before do
    sign_in super_admin
  end

  it { should use_before_action(:authenticate_pro_super_admin!) }

  describe 'index' do
    let(:image_count) { 5 }

    before do
      @images = image_count.times.map do |i|
        image = Admin::Image.new
        image.remote_image_url = "http://placehold.it/#{i + 1}00"
        image.save

        { thumb: image.small, image: image.url }
      end
    end

    it { expect(response).to have_http_status(:success) }

    it 'returns all of the images' do
      get :index

      expect(json(response)).to be_kind_of(Array)
      expect(json(response)).to match_array(@images.as_json)
    end
  end

  # describe 'create' do
  #   let(:image) { fixture_file_upload('images/10.gif', 'image/gif') }
  #
  #   before do
  #     AdminUploader.enable_processing = true
  #   end
  #
  #   after do
  #     AdminUploader.enable_processing = false
  #   end
  #
  #   it 'creates a new image' do
  #     expect { post :create, upload: image }.to change { Admin::Image.count }.by(1)
  #   end
  # end
end

def json(response)
  JSON.parse(response.body)
end
