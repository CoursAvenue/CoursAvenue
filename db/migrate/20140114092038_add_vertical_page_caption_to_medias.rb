class AddVerticalPageCaptionToMedias < ActiveRecord::Migration
  def change
    add_column :medias, :vertical_page_caption, :string
  end
end
