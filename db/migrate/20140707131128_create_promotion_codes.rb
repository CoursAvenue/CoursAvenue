class CreatePromotionCodes < ActiveRecord::Migration
  def change
    create_table :promotion_codes do |t|
      t.string  :name
      t.string  :code_id, unique: true
      t.integer :promo_amount
      t.string  :plan_type
      t.date    :expires_at
      t.integer :usage_nb, default: 0
      t.integer :max_usage_nb

      t.timestamps
    end
  end
end
