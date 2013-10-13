class AddFormatToMedias < ActiveRecord::Migration
  def change
    add_column :medias, :format, :string
    add_index :medias, :format
    Media.all.map{|media| media.send(:update_format) }
  end
end
