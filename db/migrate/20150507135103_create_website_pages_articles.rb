class CreateWebsitePagesArticles < ActiveRecord::Migration
  def change
    create_table :website_page_articles do |t|
      t.references :website_page, index: true

      t.string     :slug
      t.string     :title
      t.text       :content

      t.datetime   :deleted_at
    end
  end
end
