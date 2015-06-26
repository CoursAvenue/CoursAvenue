class RemoveSponsorshipSlugFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :sponsorship_slug
    remove_column :users, :sponsorship_id
  end

  def down
    add_column :users, :sponsorship_slug, :string
    add_column :users, :sponsorship_id, :integer
  end
end
