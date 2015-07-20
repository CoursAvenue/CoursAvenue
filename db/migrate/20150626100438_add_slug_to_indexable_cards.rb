class AddSlugToIndexableCards < ActiveRecord::Migration
  def change
    add_column :indexable_cards, :slug, :string
  end
end
