class AddImageToNewsletterBlocImage < ActiveRecord::Migration
  def change
    add_column :newsletter_blocs, :image, :string
  end
end
