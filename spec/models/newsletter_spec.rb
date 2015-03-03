require 'rails_helper'

RSpec.describe Newsletter, type: :model do
  it { should validate_presence_of :title }
  it { should validate_presence_of :content }
  it { should validate_presence_of :state }
  it { should belong_to(:structure) }

  subject         { FactoryGirl.create(:newsletter) }
  let(:structure) { subject.structure }
end
