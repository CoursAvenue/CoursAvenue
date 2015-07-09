require 'rails_helper'

RSpec.describe Ratp::Line, type: :model do
  context 'validations' do
    it { validate_presence_of(:name) }
    it { validate_presence_of(:route_name) }
  end

  context 'association' do
    it { should have_many(:stops).class_name('Ratp::Stop').through(:positions) }
    it { should have_many(:positions).class_name('Ratp::Position') }
  end

  subject { FactoryGirl.create(:ratp_line) }
end
