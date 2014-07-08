class AddPromotionCodeIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :promotion_code_id, :integer
  end
end
