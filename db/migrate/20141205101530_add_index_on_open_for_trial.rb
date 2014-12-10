class AddIndexOnOpenForTrial < ActiveRecord::Migration
  def change
    add_index :courses, :is_open_for_trial
  end
end
