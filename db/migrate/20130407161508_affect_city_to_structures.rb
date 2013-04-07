class AffectCityToStructures < ActiveRecord::Migration
  def up
    Structure.all.each do |structure|
      if structure.city.nil?
        if structure.zip_code.nil?
          structure.update_column :zip_code, '75000'
        end
        city = City.where{zip_code == structure.zip_code}.first
        structure.update_column :city_id, city.id
      end
    end
  end

  def down
  end
end
