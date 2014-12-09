class AddIndexOnMediasMediaTypeAndMediaId < ActiveRecord::Migration
  def change
    add_index :medias, [:mediable_id, :mediable_type]
  end
end
