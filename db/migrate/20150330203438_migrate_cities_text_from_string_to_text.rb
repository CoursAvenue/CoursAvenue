class MigrateCitiesTextFromStringToText < ActiveRecord::Migration
  def change
    change_column :structures, :cities_text, :text
  end
end
