class CreateCitiesUsersJoinTable < ActiveRecord::Migration
  def change
    create_table :lived_places do |t|
      t.references :city, :user
      t.string :zip_code
      t.float :radius
    end
    add_index :lived_places, [:city_id, :user_id]
  end
end
