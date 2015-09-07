class AddLogoToPressArticles < ActiveRecord::Migration
  def change
    add_column :press_articles, :logo, :string
    rename_column :press_articles, :logo_file_name, :old_logo_file_name
    rename_column :press_articles, :logo_content_type, :old_logo_content_type
    rename_column :press_articles, :logo_file_size, :old_logo_file_size
    rename_column :press_articles, :logo_updated_at, :old_logo_updated_at

    if Rails.env.production?
      bar = ProgressBar.new(PressArticle.where.not(old_logo_file_name: nil).count)
      PressArticle.where.not(old_logo_file_name: nil).find_each do |press_article|
        bar.increment!
        next if press_article.old_logo.blank?
        press_article.remote_logo_url = press_article.old_logo.url
        press_article.save
      end
    end
  end
end
