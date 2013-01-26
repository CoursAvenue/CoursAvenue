class AddIndexesForMainTables < ActiveRecord::Migration
  def change
    add_index :audiences      , :name
    add_index :levels         , :name
    add_index :plannings      , :week_day
    add_index :courses        , :type
    add_index :structures     , :city
    #add_index :prices         , :approximate_price_per_course
  end
end
