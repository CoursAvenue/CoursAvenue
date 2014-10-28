class RenameSponsoredUserToSponsorships < ActiveRecord::Migration
  def change
    rename_table :sponsored_users, :sponsorships
  end
end
