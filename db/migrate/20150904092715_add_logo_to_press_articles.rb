class AddLogoToPressArticles < ActiveRecord::Migration
  def change
    add_column :press_articles, :logo, :string
    rename_column :press_articles, :logo_file_name, :old_logo_file_name
    rename_column :press_articles, :logo_content_type, :old_logo_content_type
    rename_column :press_articles, :logo_file_size, :old_logo_file_size
    rename_column :press_articles, :logo_updated_at, :old_logo_updated_at
  end
end
