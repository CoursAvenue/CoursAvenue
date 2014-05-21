class MigratePromoPercentageToPromoAmount < ActiveRecord::Migration
  def change
    bar = ProgressBar.new Price.where.not(promo_percentage: nil).count
    Price.where.not(promo_percentage: nil).each do |price|
      bar.increment!
      price.update_column :promo_amount, price.promo_percentage
      price.update_column :promo_amount_type, '%'
    end
  end
end
