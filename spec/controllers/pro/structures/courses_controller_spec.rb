require "rails_helper"

describe Pro::Structures::CoursesController do
  include Devise::TestHelpers
  let(:admin) { FactoryGirl.create(:admin) }

  before do
    sign_in admin
  end

  describe "GET #configure_openings" do
    it 'renders' do
      get :configure_openings, structure_id: admin.structure.slug
      expect(response.status).to eq(200)
    end
  end

  describe "PATCH #update_openings" do
    let(:course) { FactoryGirl.create(:course, structure: admin.structure) }
    it 'updates start_date and end_date' do
      start_date_unix = 1.month.ago.to_i
      end_date_unix   = 1.month.from_now.to_i
      patch :update_openings, { structure_id: admin.structure.slug,
                                courses: { '0' => {
                                  id: course.id,
                                  start_date_unix: start_date_unix,
                                  end_date_unix: end_date_unix
                                }}
                              }

      expect(response.status).to eq(302)
      expect(course.reload.start_date).to eq Time.at(start_date_unix).to_date
      expect(course.end_date).to eq Time.at(end_date_unix).to_date
    end
  end
end
