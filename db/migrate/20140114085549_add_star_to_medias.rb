class AddStarToMedias < ActiveRecord::Migration
  def change
    add_column :medias, :star, :boolean
  end
end
