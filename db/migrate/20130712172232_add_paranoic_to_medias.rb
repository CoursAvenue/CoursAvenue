class AddParanoicToMedias < ActiveRecord::Migration
  def change
    add_column :medias, :deleted_at, :time
  end
end
