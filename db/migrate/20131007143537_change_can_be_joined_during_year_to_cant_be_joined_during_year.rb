class ChangeCanBeJoinedDuringYearToCantBeJoinedDuringYear < ActiveRecord::Migration
  def up
    rename_column :courses, :can_be_joined_during_year, :cant_be_joined_during_year
    Course.update_all cant_be_joined_during_year: false
  end

  def down
  end
end
