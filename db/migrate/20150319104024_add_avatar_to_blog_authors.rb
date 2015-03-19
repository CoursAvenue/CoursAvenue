class AddAvatarToBlogAuthors < ActiveRecord::Migration
  def change
    add_column :blog_authors, :avatar, :string
  end
end
