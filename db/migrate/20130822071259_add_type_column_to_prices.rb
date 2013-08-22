class AddTypeColumnToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :type, :string
    add_column :prices, :number, :integer
    add_index :prices, :type
  end
end
