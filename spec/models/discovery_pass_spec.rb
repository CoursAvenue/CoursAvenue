require 'spec_helper'

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

      before(:each) do
        sponsored_user.confirm!
        sponsorship.reload
      end

      # TODO: I shouldn't have to reload the sponsoship twice.
      it 'applies the sponsorship promo' do
        sponsored_user.discovery_passes.create
        sponsorship.reload

        expect(sponsorship.state).to eq "bought"
      end

      it "updates the sponsor's credit" do
        expect { sponsored_user.discovery_passes.create }.to change { sponsor.sponsorship_credit }.by(Sponsorship::USER_WHO_SPONSORED_CREDIT)
      end

      it "updates the sponsored user's credit" do
        expect { sponsored_user.discovery_passes.create }.to change { sponsored_user.sponsorship_credit }.by(Sponsorship::USER_WHO_HAVE_BEEN_SPONSORED_CREDIT)
      end
    end
  end
end
