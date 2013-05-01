class ChangeDurationTypeToMinutes < ActiveRecord::Migration
  def up
    remove_column :plannings, :duration
    add_column    :plannings, :duration, :integer
    Planning.all.each do |planning|
      if planning.end_time and planning.start_time
        time_at = Time.at(planning.end_time - planning.start_time)
        planning.update_column :duration, (time_at.hour * 60) + time_at.min
      end
    end
  end

  def down
    remove_column :plannings, :duration
    add_column    :plannings, :duration, :date
  end
end
