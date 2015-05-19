class CreateWebsitePages < ActiveRecord::Migration
  def change
    create_table :website_pages do |t|
      t.references :structure, index: true
      t.string     :slug
      t.string     :title
      t.datetime   :deleted_at

      t.timestamps
    end
  end
end
