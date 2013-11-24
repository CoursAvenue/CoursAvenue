class AddFilepickerUrlToMedias < ActiveRecord::Migration
  def change
    add_column :medias, :filepicker_url, :string
  end
end
