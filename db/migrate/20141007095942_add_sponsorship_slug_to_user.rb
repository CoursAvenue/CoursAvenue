class AddSponsorshipSlugToUser < ActiveRecord::Migration
  def change
    add_column :users, :sponsorship_slug, :string
  end
end
