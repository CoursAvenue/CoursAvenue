class ChangePriceInfoToText < ActiveRecord::Migration
  def up
    change_column :prices, :info, :text
  end

  def down
  end
end
