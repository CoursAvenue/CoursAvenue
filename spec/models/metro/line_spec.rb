require 'rails_helper'

RSpec.describe Metro::Line, type: :model do
  context 'validations' do
    it { validate_presence_of(:name) }
    it { validate_presence_of(:route_name) }
  end

  context 'association' do
    # TODO: Find why this fails when it shouldn't.
    it { should have_and_belong_to_many(:stops).class_name('Metro::Stop') }
  end

  subject { FactoryGirl.create(:metro_line) }
end
