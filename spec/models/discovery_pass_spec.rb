require 'spec_helper'

describe DiscoveryPass, :type => :model do
  context :sponsorship do
    describe '#apply_sponsorship_promo' do
      let (:user)           { FactoryGirl.create(:user) }
      let (:sponsored_user) { FactoryGirl.create(:user) }
      let (:sponsorship)    { user.sponsorships.create(sponsored_user: sponsored_user) }

      # TODO: I shouldn't have to reload the sponsoship twice.
      it 'applies the sponsorship promo' do
        sponsored_user.confirm!
        sponsorship.reload
        sponsored_user.discovery_passes.create
        sponsorship.reload

        expect(sponsorship.state).to eq "bought"
      end

      it "updates the sponsor's credit" do
        expect { sponsored_user.discovery_passes.create }.to change { user.sponsorship_credit }.by(Sponsorship::SPONSOR_CREDIT)
      end

      it "updates the sponsored user's credit" do
        expect { sponsored_user.discovery_passes.create }.to change { sponsored_user.sponsorship_credit }.by(Sponsorship::SPONSORED_CREDIT)
      end
    end
  end
end
