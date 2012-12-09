class AddIndexesForMainTables < ActiveRecord::Migration
  def up
    add_index :audiences      , :name
    add_index :levels         , :name
    add_index :prices         , :approximate_price_per_course
    add_index :plannings      , :week_day
    add_index :course_groups  , :type
  end

  def down
    remove_index :audiences      , :name
    remove_index :levels         , :name
    remove_index :prices         , :approximate_price_per_course
    remove_index :plannings      , :week_day
    remove_index :course_groups  , :type
  end
end
