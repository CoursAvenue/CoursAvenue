class RemovePlanningsColumns < ActiveRecord::Migration
  def up
    remove_column :plannings, :day_one
    remove_column :plannings, :day_one_duration
    remove_column :plannings, :day_one_start_time
    remove_column :plannings, :day_two
    remove_column :plannings, :day_two_duration
    remove_column :plannings, :day_two_start_time
    remove_column :plannings, :day_three
    remove_column :plannings, :day_three_duration
    remove_column :plannings, :day_three_start_time
    remove_column :plannings, :day_four
    remove_column :plannings, :day_four_duration
    remove_column :plannings, :day_four_start_time
    remove_column :plannings, :day_five
    remove_column :plannings, :day_five_duration
    remove_column :plannings, :day_five_start_time
  end

  def down
    add_column :plannings, :day_one, :date
    add_column :plannings, :day_one_duration, :time
    add_column :plannings, :day_one_start_time, :time
    add_column :plannings, :day_two, :date
    add_column :plannings, :day_two_duration, :time
    add_column :plannings, :day_two_start_time, :time
    add_column :plannings, :day_three, :date
    add_column :plannings, :day_three_duration, :time
    add_column :plannings, :day_three_start_time, :time
    add_column :plannings, :day_four, :date
    add_column :plannings, :day_four_duration, :time
    add_column :plannings, :day_four_start_time, :time
    add_column :plannings, :day_five, :date
    add_column :plannings, :day_five_duration, :time
    add_column :plannings, :day_five_start_time, :time
  end
end
