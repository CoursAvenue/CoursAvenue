require 'rails_helper'

RSpec.describe Metro::Stop, type: :model do
  context 'validations' do
    it { validate_presence_of(:name) }
    it { validate_presence_of(:latitude) }
    it { validate_presence_of(:longitude) }
  end

  context 'association' do
    it { should have_many(:lines).class_name('Metro::Line') }
  end

  subject { FactoryGirl.create(:metro_stop) }
end
