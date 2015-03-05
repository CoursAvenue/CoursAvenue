class AddContentToNewsletterBlocs < ActiveRecord::Migration
  def change
    add_column :newsletter_blocs, :content, :text
  end
end
