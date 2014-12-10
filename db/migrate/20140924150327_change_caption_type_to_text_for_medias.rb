class ChangeCaptionTypeToTextForMedias < ActiveRecord::Migration
  def change
    change_column :medias, :caption, :text
  end
end
