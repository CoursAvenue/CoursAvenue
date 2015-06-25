require 'rails_helper'

describe DiscoveryPass, :type => :model do
  context :sponsorship do
    describe '#apply_sponsorship_promo' do
      let (:sponsor)        { FactoryGirl.create(:user) }
      let (:sponsored_user) {
        user = FactoryGirl.build(:user_redux)
        user.save(validate: false)
        user
      }
      let (:sponsorship)    { sponsor.sponsorships.create(sponsored_user: sponsored_user) }

      # TODO: I shouldn't have to reload the sponsoship twice.
      it 'applies the sponsorship promo' do
        sponsored_user.discovery_passes.create
        sponsorship.reload

        expect(sponsorship.state).to eq "bought"
      end

      it "updates the sponsor's next amount" do
        sponsor.discovery_passes.create

        expect { sponsored_user.discovery_passes.create }.to change { sponsor.discovery_passes.first.next_amount }.by(- Sponsorship::USER_WHO_SPONSORED_CREDIT)
      end

      it "updates the sponsor's remaining credit" do
        sponsor.discovery_passes.create

        expect { sponsored_user.discovery_passes.create }.to change { sponsor.discovery_passes.last.next_remaining_credit }.by(- Sponsorship::USER_WHO_SPONSORED_CREDIT)
      end

      it "updates the sponsored user's credit" do
        pass = sponsored_user.discovery_passes.create

        expect { pass.sponsorship = sponsorship }.to change { pass.amount }.by(- Sponsorship::USER_WHO_HAVE_BEEN_SPONSORED_CREDIT)
      end
    end
  end
end
