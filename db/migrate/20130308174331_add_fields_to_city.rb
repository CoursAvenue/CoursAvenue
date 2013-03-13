class AddFieldsToCity < ActiveRecord::Migration
  def change
    add_column :cities, :iso_code, :string
    add_column :cities, :zip_code, :string
    add_column :cities, :region_name, :string
    add_column :cities, :region_code, :string
    add_column :cities, :department_name, :string
    add_column :cities, :department_code, :string
    add_column :cities, :commune_name, :string
    add_column :cities, :commune_code, :string
    add_column :cities, :latitude, :float
    add_column :cities, :longitude, :float
    add_column :cities, :acuracy, :integer
    Rake::Task['import:cities'].invoke
  end
end
