class AddTokenToNewsletters < ActiveRecord::Migration
  def change
    add_column :newsletters, :token, :string
  end
end
