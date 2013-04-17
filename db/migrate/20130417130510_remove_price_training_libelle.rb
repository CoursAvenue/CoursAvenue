class RemovePriceTrainingLibelle < ActiveRecord::Migration
  def up
    Price.where{libelle == 'prices.training'}.all.each do |price|
      price.update_attribute(:libelle, 'prices.individual_course')
    end
  end

  def down
  end
end
