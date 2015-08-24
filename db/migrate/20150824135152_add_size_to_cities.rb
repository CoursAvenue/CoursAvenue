class AddSizeToCities < ActiveRecord::Migration
  def change
    add_column :cities, :size, :integer, default: 1
    %w(paris marseille lyon toulouse nice nantes strasbourg montpellier bordeaux lille).each do |city_slug|
      City.find(city_slug).update_column :size, 3
    end
  end
end
