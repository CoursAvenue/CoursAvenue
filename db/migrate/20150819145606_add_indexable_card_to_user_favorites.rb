class AddIndexableCardToUserFavorites < ActiveRecord::Migration
  def change
    add_reference :user_favorites, :indexable_card, index: true
  end
end
