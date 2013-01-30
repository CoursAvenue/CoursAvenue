class CreatePlannings < ActiveRecord::Migration
  def change
    create_table :plannings do |t|
      t.date    :start_date
      t.date    :end_date
      t.string  :recurrence
      t.date    :day_one
      t.time    :day_one_start_time
      t.time    :day_one_duration
      t.date    :day_two
      t.time    :day_two_start_time
      t.time    :day_two_duration
      t.date    :day_three
      t.time    :day_three_start_time
      t.time    :day_three_duration
      t.date    :day_four
      t.time    :day_four_start_time
      t.time    :day_four_duration
      t.date    :day_five
      t.time    :day_five_start_time
      t.time    :day_five_duration
      t.integer :week_day # 1 = monday
      t.time    :start_time
      t.time    :end_time
      t.time    :duration
      t.boolean :class_during_holidays
      t.decimal :promotion
      t.integer :nb_place_available
      t.text    :info
      t.references :course

      t.timestamps
    end
  end
end
