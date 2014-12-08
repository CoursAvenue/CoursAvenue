require "spec_helper"

describe Pro::SubjectsController do
  before do
    Rails.cache.clear
  end

  # let(:parent_subject)   { FactoryGirl(:subject) }
  let(:subject_children) { FactoryGirl.create(:subject_children) }

  describe "GET #index" do
    it "'s forbidden" do
      get :descendants, format: :json, ids: subject_children.root.id.to_s
      expect(response.body).to include subject_children.name
    end
  end
end
