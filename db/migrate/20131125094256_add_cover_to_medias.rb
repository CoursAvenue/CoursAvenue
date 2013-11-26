class AddCoverToMedias < ActiveRecord::Migration
  def change
    add_column :medias, :cover, :boolean, default: false
  end
end
