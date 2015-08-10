class AddPopularityToIndexableCards < ActiveRecord::Migration
  def change
    add_column :indexable_cards, :popularity, :integer
  end
end
