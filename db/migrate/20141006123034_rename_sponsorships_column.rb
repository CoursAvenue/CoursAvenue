class RenameSponsorshipsColumn < ActiveRecord::Migration
  def change
    rename_column :sponsorships, :invited_user, :sponsored_user
  end
end
