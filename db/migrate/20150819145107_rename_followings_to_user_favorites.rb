class RenameFollowingsToUserFavorites < ActiveRecord::Migration
  def change
    rename_table :followings, :user_favorites
  end
end
