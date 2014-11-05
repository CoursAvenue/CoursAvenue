class AddCityTextToEmailingSectionBridge < ActiveRecord::Migration
  def change
    add_column :emailing_section_bridges, :city_text, :string
  end
end
