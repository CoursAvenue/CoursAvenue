class AddTypeToMedias < ActiveRecord::Migration
  def change
    add_column :medias, :type, :string
  end
end
