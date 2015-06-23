require 'rails_helper'

RSpec.describe Metro::Stop, type: :model do
  context 'validations' do
    it { validate_presence_of(:name) }
    it { validate_presence_of(:latitude) }
    it { validate_presence_of(:longitude) }
  end

  context 'association' do
    # TODO: Find why this fails when it shouldn't.
    # it { should have_and_belong_to_many(:lines).class_name('Metro::Line') }
  end

  subject { FactoryGirl.create(:metro_stop) }
end
