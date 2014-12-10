require 'rails_helper'

describe Sponsorship, :type => :model do
  context 'callbacks' do
    describe '#set promo_code' do
      let (:user)           { FactoryGirl.create(:user) }
      let (:sponsored_user) {
        user = FactoryGirl.build(:user_redux)
        user.save(validate: false)
        user
      }

      it 'sets the promo code after the sponsorship is created' do
        sponsorship = user.sponsorships.create(sponsored_user: sponsored_user)

        expect(sponsorship.promo_code).to_not be_nil
      end
    end
  end
end
