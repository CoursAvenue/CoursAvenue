class DropTablePromoCodes < ActiveRecord::Migration
  def change
    drop_table :promotion_codes
  end
end
