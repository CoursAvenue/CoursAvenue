class AddIndexesForMainTables < ActiveRecord::Migration
  def change
    add_index :audiences      , :name
    add_index :levels         , :name
    add_index :prices         , :approximate_price_per_course
    add_index :plannings      , :week_day
    add_index :course_groups  , :type
    add_index :structures     , :city
  end
end
