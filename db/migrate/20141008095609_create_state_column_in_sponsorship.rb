class CreateStateColumnInSponsorship < ActiveRecord::Migration
  def change
    add_column :sponsorships, :state, :string
    remove_column :sponsorships, :registered
  end
end
