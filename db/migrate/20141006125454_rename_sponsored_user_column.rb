class RenameSponsoredUserColumn < ActiveRecord::Migration
  def change
    rename_column :sponsorships, :sponsored_user, :sponsored_user_id
  end
end
