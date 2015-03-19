class CreateBlogAuthors < ActiveRecord::Migration
  def change
    create_table :blog_authors do |t|
      t.string :name
      t.text   :description

      t.timestamps
    end
  end
end
