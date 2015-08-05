class AddDeletedAtToIndexableCards < ActiveRecord::Migration
  def change
    add_column :indexable_cards, :deleted_at, :datetime
  end
end
