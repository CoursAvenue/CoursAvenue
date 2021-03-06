require 'rails_helper'

RSpec.describe Ratp::Stop, type: :model do
  context 'validations' do
    it { validate_presence_of(:name) }
    it { validate_presence_of(:latitude) }
    it { validate_presence_of(:longitude) }
  end

  context 'association' do
    # TODO: Find why this fails when it shouldn't.
    it { should have_many(:lines).class_name('Ratp::Line').through(:positions) }
  end
end
