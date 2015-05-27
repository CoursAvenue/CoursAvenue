require 'rails_helper'

RSpec.describe GiftCertificate, type: :model do
  context 'associations' do
    it { should belong_to(:structure) }
    it { should have_many(:vouchers).class_name('GiftCertificate::Voucher') }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:description) }

    it { should validate_numericality_of(:amount).is_greater_than(GiftCertificate::MIN_AMOUNT) }
  end
end
