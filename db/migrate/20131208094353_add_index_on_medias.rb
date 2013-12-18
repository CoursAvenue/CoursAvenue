class AddIndexOnMedias < ActiveRecord::Migration
  def change
    add_index :medias, :mediable_id
    add_index :medias, :mediable_type
  end
end
