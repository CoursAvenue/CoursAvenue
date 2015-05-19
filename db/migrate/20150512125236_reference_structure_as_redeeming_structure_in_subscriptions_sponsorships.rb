class ReferenceStructureAsRedeemingStructureInSubscriptionsSponsorships < ActiveRecord::Migration
  def change
    add_reference :subscriptions_sponsorships, :redeeming_structure, references: :structures
  end
end
