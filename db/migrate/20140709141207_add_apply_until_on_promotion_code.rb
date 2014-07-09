class AddApplyUntilOnPromotionCode < ActiveRecord::Migration
  def change
    add_column :promotion_codes, :apply_until, :date
  end
end
