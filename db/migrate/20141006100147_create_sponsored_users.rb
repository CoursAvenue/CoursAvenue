class CreateSponsoredUsers < ActiveRecord::Migration
  def change
    create_table :sponsored_users do |t|
      t.belongs_to :user
      t.integer :invited_user
      t.boolean :registered

      t.timestamps
    end
  end
end
