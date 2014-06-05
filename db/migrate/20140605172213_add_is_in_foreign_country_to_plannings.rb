class AddIsInForeignCountryToPlannings < ActiveRecord::Migration
  def change
    add_column :plannings, :is_in_foreign_country, :boolean, default: false
  end
end
