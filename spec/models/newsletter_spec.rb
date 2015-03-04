require 'rails_helper'

RSpec.describe Newsletter, type: :model do
  it { should validate_presence_of :title }
  it { should validate_presence_of :content }
  it { should validate_presence_of :state }
  it { should belong_to(:structure) }

  subject          { FactoryGirl.create(:newsletter) }
  let!(:structure) { subject.structure }

  describe 'defaults' do
    it 'is a draft by default' do
      expect(subject.state).to eq('draft')
    end

    it 'sets the default sender name' do
      expect(subject.sender_name).to eq(structure.name)
    end

    it 'sets the default reply to address' do
      expect(subject.reply_to).to eq(structure.contact_email)
    end

    it 'sets the default object' do
      expect(subject.object).to eq(subject.title)
    end
  end

end
