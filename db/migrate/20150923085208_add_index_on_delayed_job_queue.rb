class AddIndexOnDelayedJobQueue < ActiveRecord::Migration
  def change
    add_index :delayed_jobs, :queue
  end
end
