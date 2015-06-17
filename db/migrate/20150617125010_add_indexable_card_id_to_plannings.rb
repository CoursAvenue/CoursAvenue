class AddIndexableCardIdToPlannings < ActiveRecord::Migration
  def change
    add_column :plannings, :indexable_card_id, :integer
    add_index :plannings, :indexable_card_id
  end
end
